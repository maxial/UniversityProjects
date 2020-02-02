{-
  Реализуйте клиент и сервер службы суммирования по заданному модулю.

  Клиент посылает серверу последовательность строк, каждая из которых
  содержит одно положительное целое число (числа вводятся пользователем).
  В конце последовательности передаётся число 0. Сервер после получения
  всей последовательности отправляет клиенту сумму элементов
  последовательности по заданному модулю и закрывает соединение.

  Основная программа должна запускаться либо в режиме сервера, либо
  в режиме клиента (в зависимости от параметров командной строки).
  При запуске в режиме сервера в параметрах дополнительно передаётся
  значение модуля, по которому следует вести суммирование.

-}

import Network
import Control.Monad.State
import Control.Monad.Reader
import Text.Printf
import System.IO
import Control.Concurrent

port :: Int
port = 55555

client :: IO ()
client = undefined

type Modulus = Integer
type Sum = Integer

talk :: Handle -> ReaderT Modulus (StateT Sum IO) ()
talk h = do
  liftIO $ hSetBuffering h LineBuffering
  loop
 where
  loop = undefined

server :: Modulus -> IO ()
server mod = withSocketsDo $ do
  sock <- listenOn (PortNumber (fromIntegral port))
  printf "Listening on port %d\n" port
  forever $ do
    (handle, host, port) <- accept sock
    printf "Accepted connection from %s: %s\n" host 
                                             (show port)
    forkFinally (evalStateT (runReaderT (talk handle) mod) 0) (\_ -> hClose handle)

main = undefined
