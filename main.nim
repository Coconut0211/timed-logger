import logging, os, times, strutils, sequtils, algorithm

type
  TimedRollingFileHandler = ref object of Logger
    ## Обработчик логов
    ## filename - имя файла
    ## whenInterval - 'D' - день, 'H' - час, 'M' - минута, 'S' - секунда
    ## interval - заданный интервал
    ## backupCount - максимальное число файлов
    ## currentFile - текущий файл для записи
    ## nextRolloverTime - когда следующая ротация
    filename: string
    whenInterval: char  
    interval: int
    backupCount: int
    currentFile: File
    nextRolloverTime: Time

proc calculateNextRolloverTime(whenInterval: char, interval: int): Time =
  ## Вычисляет время следующей ротации.
  ## 
  ## now = getTime()
  ## now + initTimeInterval(<whatInerval::days|hours|minutes|seconds> = interval)
  ## 
  ## Если интервал не поддерживается, то вызвать ошибку.
  ## 
  ## Рекомендуется использовать case


proc newTimedRotatingFileHandler(
    filename: string,
    whenInterval: char,
    interval: int,
    backupCount: int,
    fmtStr: string
  ): TimedRollingFileHandler =
  ## Создает новый обработчик с ротацией по времени.
  new(result)
  result.filename = filename
  result.fmtStr = fmtStr
  result.whenInterval = whenInterval
  result.interval = interval
  result.backupCount = backupCount
  result.currentFile = open(filename, fmAppend)
  result.nextRolloverTime = calculateNextRolloverTime(result.whenInterval, result.interval)


proc rotateFile(logger: TimedRollingFileHandler) =
  ## Выполняет ротацию файла.

  # Проверьте на пустоту текущий файл logger.currentFile. Если файл есть, то закройте его.

  # Запишите время ротации в переменную, отформатировав время в формате "yyyy'_'MM'_'dd'_'HH'_'mm'_'ss"
  # Задайте новое имя файла, включающее время ротации
  # Используйте moveFile для перемещения файла.

  # Задайте новый logger.currentFile

  # Удаляем старые файлы, если их слишком много
  var logFiles = toSeq(walkFiles("*.log"))  # Так можно получить список всех логов, если изначально задано такое расширение.
  logFiles.sort() # Отсортируем по старшинству
  if logFiles.len > logger.backupCount:
    for i in 0 ..< logFiles.len - logger.backupCount:
      removeFile(logFiles[i])

  # Обновляем время следующей ротации
  logger.nextRolloverTime = calculateNextRolloverTime(logger.whenInterval, logger.interval)


proc log(logger: TimedRollingFileHandler, level: Level, args: varargs[string, `$`]) =
  ## Процедура для записи логов.
  let now = getTime()  # Время вызова записи лога
  if now >= logger.nextRolloverTime:
    logger.rotateFile()
  let message = args.join(" ")  # Объединяем переданные строки в одну
  var fmtStr = logger.fmtStr
  # В переменной fmtStr хранится то, что пришло в качестве аргумента fmtStr
  # В нашем случае, это [$date $time][$levelname]
  # Необходимо заменить в соответствии с принятыми стандартами:
  # $date -> now.format("yyyy-MM-dd")
  # $time -> now.format("HH:mm:ss")
  # $datetime -> now.format("yyyy-MM-dd'T'HH:mm:ss")
  # $app -> getAppFilename()
  # $appdir -> getAppFilename().splitFile.dir
  # $appname -> getAppFilename().splitFile.name
  # $levelid -> $LevelNames[level][0]
  # $levelid -> LevelNames[level]
  logger.currentFile.writeLine(fmtStr & message)  # Записываем данные в файл
  logger.currentFile.flushFile()  # Принудительно освобождаем поток вывода

# Пример использования
var logger = newTimedRotatingFileHandler(
    filename="app.log",
    whenInterval='S',
    interval=5,
    backupCount=5,
    fmtStr="[$date $time][$levelname] "
)

while true:
  logger.log(lvlDebug, "1")
  logger.log(lvlInfo, "2")
  logger.log(lvlNotice, "3")
  logger.log(lvlWarn, "4")
  logger.log(lvlError, "5")
  logger.log(lvlFatal, "6")
  sleep(500)