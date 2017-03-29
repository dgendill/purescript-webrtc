## Module WebRTC.RTC

#### `RTCPeerConnection`

``` purescript
data RTCPeerConnection :: Type
```

Foreign data type for [RTCPeerConnection](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection).

#### `localDescription`

``` purescript
localDescription :: RTCPeerConnection -> Maybe RTCSessionDescription
```

#### `ServerType`

``` purescript
data ServerType
  = STUN { urls :: NonEmpty Array String }
  | TURN { urls :: NonEmpty Array String, credentialType :: Maybe String, credential :: Maybe String, username :: Maybe String }
```

Either a STUN or TURN Server.
See [RTCIceServer](https://developer.mozilla.org/en-US/docs/Web/API/RTCIceServer).

##### Instances
``` purescript
EncodeJson ServerType
DecodeJson ServerType
```

#### `Ice`

``` purescript
type Ice = { iceServers :: Array ServerType }
```

An [RTCConfiguration](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/RTCPeerConnection#RTCConfiguration_dictionary) object.

#### `RTC`

``` purescript
data RTC :: Effect
```

#### `newRTCPeerConnection`

``` purescript
newRTCPeerConnection :: forall e. Ice -> Eff (rtc :: RTC | e) RTCPeerConnection
```

Creates a new [RTCPeerConnection](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection).

#### `IceEvent`

``` purescript
data IceEvent :: Type
```

Foreign type for [RTCPeerConnectionIceEvent](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnectionIceEvent).

#### `RTCIceCandidate`

``` purescript
type RTCIceCandidate = { sdpMLineIndex :: Nullable Int, sdpMid :: Nullable String, candidate :: Maybe String }
```

Foreign type for [RTCIceCandidate](https://developer.mozilla.org/en-US/docs/Web/API/RTCIceCandidate).
According to docs "this string is empty ("") if the RTCIceCandidate represents a "end of candidates"
indicator.  We will indicate it with Nothing.

#### `iceEventCandidate`

``` purescript
iceEventCandidate :: IceEvent -> Maybe RTCIceCandidate
```

Attempts to get the RTCIceCandidate from an [RTCPeerConnectionIceEvent](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnectionIceEvent).
If [there is no candidate, then ICE gathering has finished](https://www.w3.org/TR/webrtc/#dom-rtcpeerconnectioniceevent).
This function will also return Nothing if the RTCPeerConnectionIceEvent "candidate" property is set
but the [nested "candidate" property on the RTCIceCandidate](https://www.w3.org/TR/webrtc/#rtcicecandidate-interface)
is null.

#### `addIceCandidate`

``` purescript
addIceCandidate :: forall e. RTCIceCandidate -> RTCPeerConnection -> Eff (rtc :: RTC | e) Unit
```

Add a candidate to a peer connection.  Corresponds to [addIceCandidate](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/addIceCandidate).

#### `onicecandidate`

``` purescript
onicecandidate :: forall e. RTCPeerConnection -> (IceEvent -> Aff (rtc :: RTC | e) Unit) -> Aff (rtc :: RTC | e) RTCSessionDescription
```

Register an event listener when [onicecandidate](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/onicecandidate) is fired.
After all candidates have been gather (i.e. we get the "end-of-candidate" null value) return the
connection's RTCSessionDescription.  If you don't want to wait for ice candidates to finish being
collected, you use `forkAff`, e.g.

forkAff $ onicecandidate (\e -> do
  -- do something with event...
)

#### `RTCSessionDescription`

``` purescript
newtype RTCSessionDescription
  = RTCSessionDescription { sdp :: String, "type" :: String }
```

##### Instances
``` purescript
EncodeJson RTCSessionDescription
DecodeJson RTCSessionDescription
```

#### `rtcSessionDescriptionSdp`

``` purescript
rtcSessionDescriptionSdp :: RTCSessionDescription -> String
```

#### `rtcSessionDescriptionType`

``` purescript
rtcSessionDescriptionType :: RTCSessionDescription -> String
```

#### `audioVideoRTCOffer`

``` purescript
audioVideoRTCOffer :: RTCOfferOptions
```

RTCOfferOptions with audio and video set to true.

#### `noMediaRTCOffer`

``` purescript
noMediaRTCOffer :: RTCOfferOptions
```

RTCOfferOptions with audio and video set to false.

#### `newRTCSessionDescription`

``` purescript
newRTCSessionDescription :: { sdp :: String, "type" :: String } -> RTCSessionDescription
```

Manually create a new [RTCSessionDescription](https://developer.mozilla.org/en-US/docs/Web/API/RTCSessionDescription).

#### `createOffer`

``` purescript
createOffer :: forall e. RTCOfferOptions -> RTCPeerConnection -> Aff (rtc :: RTC | e) RTCSessionDescription
```

Create an RTCSessionDescription offer.  See [createOffer](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/createOffer).

#### `createAnswer`

``` purescript
createAnswer :: forall e. RTCPeerConnection -> Aff (rtc :: RTC | e) RTCSessionDescription
```

Create an RTCSessionDescription answer.  See [createAnswer](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/createAnswer).

#### `setLocalDescription`

``` purescript
setLocalDescription :: forall e. RTCSessionDescription -> RTCPeerConnection -> Aff (rtc :: RTC | e) Unit
```

Sets the local descritpoin associated with the connection. See [setLocalDescription](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/setLocalDescription).

#### `setRemoteDescription`

``` purescript
setRemoteDescription :: forall e. RTCSessionDescription -> RTCPeerConnection -> Aff (rtc :: RTC | e) Unit
```

Set remote description associated with the connection.  See [setRemoteDescription](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/setRemoteDescription)

#### `RTCDataChannel`

``` purescript
data RTCDataChannel :: Type
```

Foreign type for [RTCDataChannel](https://developer.mozilla.org/en-US/docs/Web/API/RTCDataChannel)

#### `createDataChannel`

``` purescript
createDataChannel :: forall e. String -> RTCPeerConnection -> Aff (rtc :: RTC | e) RTCDataChannel
```

Create a data channel for connection. See [createDataChannel](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/createDataChannel)

#### `send`

``` purescript
send :: forall e. String -> RTCDataChannel -> Eff (rtc :: RTC | e) Unit
```

Send a string of data over a data channel.

#### `onmessageChannel`

``` purescript
onmessageChannel :: forall e. RTCDataChannel -> Aff (rtc :: RTC | e) String
```

Register a listener on a data channel.

#### `ondataChannel`

``` purescript
ondataChannel :: forall e. RTCPeerConnection -> Aff (rtc :: RTC | e) RTCDataChannel
```

Register a listener on a connection, and return the
RTCDataChannel when the [ondatachannel](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/ondatachannel) event
is fired.


