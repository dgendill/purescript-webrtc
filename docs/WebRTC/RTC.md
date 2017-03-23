## Module WebRTC.RTC

#### `RTCPeerConnection`

``` purescript
data RTCPeerConnection :: Type
```

Foreign data type for [RTCPeerConnection](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection)

#### `ServerType`

``` purescript
data ServerType
  = STUN { urls :: NonEmpty Array String }
  | TURN { urls :: NonEmpty Array String, credentialType :: Maybe String, credential :: Maybe String, username :: Maybe String }
```

Either a STUN or TURN Server.
See [RTCIceServer](https://developer.mozilla.org/en-US/docs/Web/API/RTCIceServer)

##### Instances
``` purescript
EncodeJson ServerType
DecodeJson ServerType
```

#### `Ice`

``` purescript
type Ice = { iceServers :: Array ServerType }
```

#### `newRTCPeerConnection`

``` purescript
newRTCPeerConnection :: forall e. Ice -> Eff e RTCPeerConnection
```

#### `addStream`

``` purescript
addStream :: forall e. MediaStream -> RTCPeerConnection -> Eff e Unit
```

#### `IceEvent`

``` purescript
data IceEvent :: Type
```

#### `RTCIceCandidate`

``` purescript
type RTCIceCandidate = { sdpMLineIndex :: Nullable Int, sdpMid :: Nullable String, candidate :: String }
```

#### `iceEventCandidate`

``` purescript
iceEventCandidate :: IceEvent -> Maybe RTCIceCandidate
```

#### `addIceCandidate`

``` purescript
addIceCandidate :: forall e. RTCIceCandidate -> RTCPeerConnection -> Eff e Unit
```

#### `onicecandidate`

``` purescript
onicecandidate :: forall e. (IceEvent -> Eff e Unit) -> RTCPeerConnection -> Eff e Unit
```

#### `MediaStreamEvent`

``` purescript
type MediaStreamEvent = { stream :: MediaStream }
```

#### `onaddstream`

``` purescript
onaddstream :: forall e. (MediaStreamEvent -> Eff e Unit) -> RTCPeerConnection -> Eff e Unit
```

#### `RTCSessionDescription`

``` purescript
type RTCSessionDescription = { sdp :: String, "type" :: String }
```

#### `audioVideoRTCOffer`

``` purescript
audioVideoRTCOffer :: { offerToReceiveAudio :: Boolean, offerToReceiveVideo :: Boolean }
```

#### `noMediaRTCOffer`

``` purescript
noMediaRTCOffer :: { offerToReceiveAudio :: Boolean, offerToReceiveVideo :: Boolean }
```

#### `newRTCSessionDescription`

``` purescript
newRTCSessionDescription :: { sdp :: String, "type" :: String } -> RTCSessionDescription
```

#### `createOffer`

``` purescript
createOffer :: forall e. RTCOfferOptions -> RTCPeerConnection -> Aff e RTCSessionDescription
```

#### `createAnswer`

``` purescript
createAnswer :: forall e. RTCPeerConnection -> Aff e RTCSessionDescription
```

#### `setLocalDescription`

``` purescript
setLocalDescription :: forall e. RTCSessionDescription -> RTCPeerConnection -> Aff e Unit
```

#### `setRemoteDescription`

``` purescript
setRemoteDescription :: forall e. RTCSessionDescription -> RTCPeerConnection -> Aff e Unit
```

#### `RTCDataChannel`

``` purescript
data RTCDataChannel :: Type
```

#### `createDataChannel`

``` purescript
createDataChannel :: forall e. String -> RTCPeerConnection -> Aff e RTCDataChannel
```

#### `send`

``` purescript
send :: forall e. String -> RTCDataChannel -> Eff e Unit
```

#### `onmessageChannel`

``` purescript
onmessageChannel :: forall e. (String -> Eff e Unit) -> RTCDataChannel -> Eff e Unit
```

#### `ondataChannel`

``` purescript
ondataChannel :: forall e. RTCPeerConnection -> Aff e RTCDataChannel
```


