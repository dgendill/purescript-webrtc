module WebRTC.RTC (
  RTCPeerConnection(..)
, RTC
, RTCSessionDescription(..)
, Ice(..)
, IceEvent(..)
, RTCIceCandidate(..)
, RTCDataChannel(..)
, ServerType(..)
, newRTCPeerConnection
, onicecandidate
, createOffer
, createAnswer
, setLocalDescription
, setRemoteDescription
, newRTCSessionDescription
, iceEventCandidate
, addIceCandidate
, createDataChannel
, send
, onmessageChannelOnce
, ondataChannel
, audioVideoRTCOffer
, noMediaRTCOffer
, rtcSessionDescriptionType
, rtcSessionDescriptionSdp
, localDescription
, closeConnection
, oncloseChannel
) where

import Control.Alt ((<|>))
import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (Error)
import Data.Argonaut (class DecodeJson, class EncodeJson, Json, decodeJson, encodeJson, getField, jsonEmptyObject, jsonSingletonObject, (:=), (~>))
import Data.Maybe (Maybe(..))
import Data.NonEmpty (NonEmpty)
import Data.Nullable (Nullable)
import Prelude (Unit, bind, pure, unit, ($), (<$>))

-- | Foreign data type for [RTCPeerConnection](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection).
foreign import data RTCPeerConnection :: *

foreign import localDescription_ :: forall a. (a -> Maybe a) -> Maybe a -> RTCPeerConnection -> Maybe RTCSessionDescription


localDescription :: RTCPeerConnection -> Maybe RTCSessionDescription
localDescription = localDescription_ Just Nothing

-- | Either a STUN or TURN Server.
-- | See [RTCIceServer](https://developer.mozilla.org/en-US/docs/Web/API/RTCIceServer).
data ServerType
  = STUN { urls :: NonEmpty Array String }
  | TURN { urls :: NonEmpty Array String, credentialType :: Maybe String, credential :: Maybe String, username :: Maybe String }


-- | An [RTCConfiguration](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/RTCPeerConnection#RTCConfiguration_dictionary) object.
type Ice = {
  iceServers :: Array ServerType
}

instance serverTypeEncodeJson :: EncodeJson ServerType where
  encodeJson (STUN s) = jsonSingletonObject "urls" (encodeJson s.urls)
  encodeJson (TURN t) = (
    "urls" := t.urls
    ~> "credentialType" := t.credentialType
    ~> "credential" := t.credential
    ~> "username" := t.username
    ~> jsonEmptyObject
  )

instance serverTypeDecodeJson :: DecodeJson ServerType where
  decodeJson json' = getTurn json' <|> getStun json'
    where
      getTurn json = do
        obj <- decodeJson json
        credentialType <- getField obj "credentialType"
        credential <- getField obj "credential"
        username <- getField obj "username"
        urls <- getField obj "urls"
        pure $ TURN { credentialType, credential, username, urls }
      getStun json = do
        obj <- decodeJson json
        urls <- getField obj "urls"
        pure $ STUN { urls }

foreign import data RTC :: !

foreign import newRTCPeerConnection_
  :: forall e. { iceServers :: Array Json } -> Eff (rtc :: RTC | e) RTCPeerConnection

-- | Creates a new [RTCPeerConnection](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection).
newRTCPeerConnection :: forall e. Ice -> Eff (rtc :: RTC | e) RTCPeerConnection
newRTCPeerConnection i = newRTCPeerConnection_ { iceServers : (encodeJson <$> i.iceServers) }

-- | Foreign type for [RTCPeerConnectionIceEvent](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnectionIceEvent).
foreign import data IceEvent :: *

-- | Foreign type for [RTCIceCandidate](https://developer.mozilla.org/en-US/docs/Web/API/RTCIceCandidate).
-- | According to docs "this string is empty ("") if the RTCIceCandidate represents a "end of candidates"
-- | indicator.  We will indicate it with Nothing.
type RTCIceCandidate = { sdpMLineIndex :: Nullable Int
                       , sdpMid :: Nullable String
                       -- This string is empty ("") if the RTCIceCandidate
                       -- represents a "end of candidates" indicator.
                       , candidate :: Maybe String
                       }

foreign import _iceEventCandidate
  :: forall a. Maybe a ->
               (a -> Maybe a) ->
               IceEvent ->
               Maybe RTCIceCandidate

-- | Attempts to get the RTCIceCandidate from an [RTCPeerConnectionIceEvent](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnectionIceEvent).
-- | If [there is no candidate, then ICE gathering has finished](https://www.w3.org/TR/webrtc/#dom-rtcpeerconnectioniceevent).
-- | This function will also return Nothing if the RTCPeerConnectionIceEvent "candidate" property is set
-- | but the [nested "candidate" property on the RTCIceCandidate](https://www.w3.org/TR/webrtc/#rtcicecandidate-interface)
-- | is null.
iceEventCandidate :: IceEvent -> Maybe RTCIceCandidate
iceEventCandidate = _iceEventCandidate Nothing Just

-- | Add a candidate to a peer connection.  Corresponds to [addIceCandidate](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/addIceCandidate).
foreign import addIceCandidate
  :: forall e. RTCIceCandidate ->
               RTCPeerConnection ->
               Eff (rtc :: RTC | e) Unit

-- | Register an event listener when [onicecandidate](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/onicecandidate) is fired.
-- | After all candidates have been gather (i.e. we get the "end-of-candidate" null value) return the
-- | connection's RTCSessionDescription.  If you don't want to wait for ice candidates to finish being
-- | collected, you use `forkAff`, e.g.
-- |
-- | forkAff $ onicecandidate (\e -> do
-- |   -- do something with event...
-- | )
foreign import onicecandidate
  :: forall e. RTCPeerConnection ->
               (IceEvent -> Aff (rtc :: RTC | e) Unit) ->
               Aff (rtc :: RTC | e) RTCSessionDescription

instance rTCSessionDescriptionEncodeJSON :: EncodeJson RTCSessionDescription where
  encodeJson (RTCSessionDescription {"sdp" : sdp, "type" : t}) =
    ("sdp" := sdp
    ~> "type" := t
    ~> jsonEmptyObject)

instance rTCSessionDescriptionDecodeJSON :: DecodeJson RTCSessionDescription where
  decodeJson json = do
    obj <- decodeJson json
    sdp <- getField obj "sdp"
    t <- getField obj "type"
    pure $ RTCSessionDescription { "sdp" : sdp, "type" : t }

-- A type for [RTCSessionDescription](https://developer.mozilla.org/en-US/docs/Web/API/RTCSessionDescription)
newtype RTCSessionDescription = RTCSessionDescription { sdp :: String, "type" :: String }

-- Return the "sdp" property on the RTCSessionDescription
rtcSessionDescriptionSdp :: RTCSessionDescription -> String
rtcSessionDescriptionSdp (RTCSessionDescription r) = r.sdp

-- Return the "type" property on the RTCSessionDescription
rtcSessionDescriptionType :: RTCSessionDescription -> String
rtcSessionDescriptionType (RTCSessionDescription {"type" : t}) = t

-- https://code.google.com/p/webrtc/issues/detail?id=3282
-- https://bugzilla.mozilla.org/show_bug.cgi?id=1033833
-- http://w3c.github.io/webrtc-pc/#idl-def-RTCOfferOptions
-- | A type corresponding to [http://w3c.github.io/webrtc-pc/#configuration-data-extensions](RTCOfferOptions)
-- | used to create an RTCSessionDescription.
type RTCOfferOptions = {
  offerToReceiveAudio :: Boolean,
  offerToReceiveVideo :: Boolean
}

-- | RTCOfferOptions with audio and video set to true.
audioVideoRTCOffer :: RTCOfferOptions
audioVideoRTCOffer = {
  offerToReceiveAudio: true,
  offerToReceiveVideo: true
}

-- | RTCOfferOptions with audio and video set to false.
noMediaRTCOffer :: RTCOfferOptions
noMediaRTCOffer = {
  offerToReceiveAudio: false,
  offerToReceiveVideo: false
}

-- | Manually create a new [RTCSessionDescription](https://developer.mozilla.org/en-US/docs/Web/API/RTCSessionDescription).
foreign import newRTCSessionDescription
  :: { sdp :: String, "type" :: String } -> RTCSessionDescription

foreign import _createOffer
  :: forall e. (RTCSessionDescription -> Eff (rtc :: RTC | e) Unit) ->
               (Error -> Eff (rtc :: RTC | e) Unit) ->
               RTCOfferOptions ->
               RTCPeerConnection ->
               Eff (rtc :: RTC | e) Unit

-- | Create an RTCSessionDescription offer.  See [createOffer](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/createOffer).
createOffer :: forall e. RTCOfferOptions -> RTCPeerConnection -> Aff (rtc :: RTC | e) RTCSessionDescription
createOffer options pc = makeAff (\e s -> _createOffer s e options pc)

foreign import _createAnswer
  :: forall e. (RTCSessionDescription -> Eff (rtc :: RTC | e) Unit) ->
               (Error -> Eff (rtc :: RTC | e) Unit) ->
               RTCPeerConnection ->
               Eff (rtc :: RTC | e) Unit

-- | Create an RTCSessionDescription answer.  See [createAnswer](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/createAnswer).
createAnswer :: forall e. RTCPeerConnection -> Aff (rtc :: RTC | e) RTCSessionDescription
createAnswer pc = makeAff (\e s -> _createAnswer s e pc)

foreign import _setLocalDescription
  :: forall e. Eff (rtc :: RTC | e) Unit ->
               (Error -> Eff (rtc :: RTC | e) Unit) ->
               RTCSessionDescription ->
               RTCPeerConnection ->
               Eff (rtc :: RTC | e) Unit

-- | Sets the local descritpoin associated with the connection. See [setLocalDescription](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/setLocalDescription).
setLocalDescription :: forall e. RTCSessionDescription -> RTCPeerConnection -> Aff (rtc :: RTC | e) Unit
setLocalDescription desc pc = makeAff (\e s -> _setLocalDescription (s unit) e desc pc)

foreign import _setRemoteDescription
  :: forall e. Eff (rtc :: RTC | e) Unit ->
               (Error -> Eff (rtc :: RTC | e) Unit) ->
               RTCSessionDescription ->
               RTCPeerConnection ->
               Eff (rtc :: RTC | e) Unit

-- | Set remote description associated with the connection.  See [setRemoteDescription](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/setRemoteDescription)
setRemoteDescription :: forall e. RTCSessionDescription -> RTCPeerConnection -> Aff (rtc :: RTC | e) Unit
setRemoteDescription desc pc = makeAff (\e s -> _setRemoteDescription (s unit) e desc pc)

-- | Foreign type for [RTCDataChannel](https://developer.mozilla.org/en-US/docs/Web/API/RTCDataChannel)
foreign import data RTCDataChannel :: *


-- | Create a data channel for connection. See [createDataChannel](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/createDataChannel)
foreign import createDataChannel
  :: forall e. String ->
               RTCPeerConnection ->
               Aff (rtc :: RTC | e) RTCDataChannel

-- | Run a callback when the RTCDataChannel [onclose](https://developer.mozilla.org/en-US/docs/Web/API/RTCDataChannel/onclose)
-- | event fires.
foreign import oncloseChannel
  :: forall e. RTCDataChannel ->
               Aff (rtc :: RTC | e) Unit ->
               Aff (rtc :: RTC | e) Unit

-- | Closes a peer connection. See [close](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/close).
foreign import closeConnection
  :: forall e. RTCPeerConnection ->
               Aff (rtc :: RTC | e) Unit

-- | Send a string of data over a data channel.
foreign import send
  :: forall e. String ->
               RTCDataChannel ->
               Eff (rtc :: RTC | e) Unit

-- | Register a listener on a data channel and trigger the callback
-- | only once.
foreign import onmessageChannelOnce
  :: forall e. RTCDataChannel ->
               Aff (rtc :: RTC | e) String

-- | Register a listener on a connection, and return the
-- | RTCDataChannel when the [ondatachannel](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/ondatachannel) event
-- | is fired.
foreign import ondataChannel
  :: forall e. RTCPeerConnection ->
               Aff (rtc :: RTC | e) RTCDataChannel
