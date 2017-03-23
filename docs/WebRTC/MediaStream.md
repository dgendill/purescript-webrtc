## Module WebRTC.MediaStream

#### `MediaStream`

``` purescript
data MediaStream :: Type
```

#### `USER_MEDIA`

``` purescript
data USER_MEDIA :: Effect
```

#### `getUserMedia`

``` purescript
getUserMedia :: forall e. MediaStreamConstraints -> Aff (userMedia :: USER_MEDIA | e) MediaStream
```

#### `MediaStreamConstraints`

``` purescript
newtype MediaStreamConstraints
  = MediaStreamConstraints { video :: Boolean, audio :: Boolean }
```

#### `Blob`

``` purescript
data Blob :: Type
```

#### `mediaStreamToBlob`

``` purescript
mediaStreamToBlob :: MediaStream -> Blob
```

#### `createObjectURL`

``` purescript
createObjectURL :: forall e. Blob -> Eff e String
```


