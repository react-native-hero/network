
import { NativeModules } from 'react-native'

const { RNTNetwork } = NativeModules

export const CODE = {
  FILE_NOT_FOUND: RNTNetwork.ERROR_CODE_FILE_NOT_FOUND,
}

/**
 * 下载文件
 */
export function download(url) {
  return RNTNetwork.download(url)
}
