
import { NativeModules, NativeEventEmitter } from 'react-native'

const { RNTNetwork } = NativeModules

const eventEmitter = new NativeEventEmitter(RNTNetwork)

const index2callback = {}

let count = 0

function handleProgress(data) {
  let onProgress = index2callback[data.index]
  if (onProgress) {
    onProgress(data.progress)
  }
}

eventEmitter.addListener('download_progress', handleProgress)
eventEmitter.addListener('upload_progress', handleProgress)

export const CODE = {
  DOWNLOAD_FAILURE: RNTNetwork.ERROR_CODE_DOWNLOAD_FAILURE,
  UPLOAD_FAILURE: RNTNetwork.ERROR_CODE_UPLOAD_FAILURE,
}

/**
 * 下载文件
 */
export function download(options, onProgress) {
  if (onProgress) {
    options.index = ++count
    index2callback[options.index] = onProgress
  }
  return RNTNetwork.download(options)
    .finally(() => {
      if (onProgress) {
        delete index2callback[options.index]
      }
    })
}

/**
 * 上传文件
 */
export function upload(options, onProgress) {
  if (onProgress) {
    options.index = ++count
    index2callback[options.index] = onProgress
  }
  return RNTNetwork.upload(options)
    .finally(() => {
      if (onProgress) {
        delete index2callback[options.index]
      }
    })
}
