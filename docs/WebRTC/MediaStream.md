## Module WebRTC.MediaStream

#### `MediaStream`

``` purescript
data MediaStream :: Type
```

Foreign type for [MediaStream](https://developer.mozilla.org/en-US/docs/Web/API/Media_Streams_API#LocalMediaStream).

#### `USER_MEDIA`

``` purescript
data USER_MEDIA :: Effect
```

#### `getUserMedia`

``` purescript
getUserMedia :: forall e. MediaStreamConstraints -> Aff (userMedia :: USER_MEDIA | e) MediaStream
```

Prompt the user for audio/video permission in order to get a `MediaStream`.  See [getUserMedia](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia).

#### `MediaStreamConstraints`

``` purescript
newtype MediaStreamConstraints
  = MediaStreamConstraints { video :: Boolean, audio :: Boolean }
```

#### `Blob`

``` purescript
data Blob :: Type
```

Foreign type for [Blob](https://developer.mozilla.org/en-US/docs/Web/API/Blob).

#### `mediaStreamToBlob`

``` purescript
mediaStreamToBlob :: MediaStream -> Blob
```

Convert a `MediaStream` into a `Blob`

#### `createObjectURL`

``` purescript
createObjectURL :: forall e. Blob -> Eff e String
```

Turn a Blob into a URL.  See [createObjectURL](https://developer.mozilla.org/en-US/docs/Web/API/URL/createObjectURL).


