# @react-native-hero/network

## Getting started

Install the library using either Yarn:

```
yarn add @react-native-hero/network
```

or npm:

```
npm install --save @react-native-hero/network
```

## Link

- React Native v0.60+

For iOS, use `cocoapods` to link the package.

run the following command:

```
$ cd ios && pod install
```

For android, the package will be linked automatically on build.

- React Native <= 0.59

run the following command to link the package:

```
$ react-native link @react-native-hero/network
```

## Example

```js
import {
  CODE,
  download,
  upload,
  fetch,
} from '@react-native-hero/network'

download(
  // required
  {
    url: 'https://www.example.com/a.jpg',
    path: '/root/home/a.jpg',
  },
  // optional
  function (progress) {
    // [0, 1]
  }
).then(response => {
  response.name
  response.path
  response.size
})
.catch(err => {
  if (err.code === CODE.DOWNLOAD_FAILURE) {
    console.log('download error')
  }
})

upload(
  // required
  {
    url: 'https://www.example.com/upload',
    file: {
      path: '/root/home/a.jpg',
      name: 'file',
      mimeType: 'image/jpeg',
      // optional, default value is the file name of path
      fileName: 'a.jpg',
    },
    // optional, send request params
    data: {
      key1: 'value1',
      key2: 'value2',
    },
    // optional, set request headers
    headers: {

    }
  },
  // optional
  function (progress) {
    // [0, 1]
  }
).then(response => {
  response.status_code
  response.body
})
.catch(err => {
  if (err.code === CODE.UPLOAD_FAILURE) {
    console.log('upload error')
  }
})

fetch({
  url: '',
  methods: 'post',
  // optional, send request params
  data: {
    key1: 'value1',
    key2: 'value2',
  },
  // optional, set request headers
  headers: {

  }
})
.then(response => {
  response.status_code
  response.body
})
.catch(err => {
  if (err.code === CODE.FETCH_FAILURE) {
    console.log('fetch error')
  }
})
```
