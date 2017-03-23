module WebRTC.RTC (
  RTCPeerConnection(..)
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
, onmessageChannel
, ondataChannel
, audioVideoRTCOffer
, noMediaRTCOffer
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


foreign import newRTCPeerConnection_
  :: forall e. { iceServers :: Array Json } -> Eff e RTCPeerConnection

-- | Creates a new [RTCPeerConnection](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection).
newRTCPeerConnection :: forall e. Ice -> Eff e RTCPeerConnection
newRTCPeerConnection i = newRTCPeerConnection_ { iceServers : (encodeJson <$> i.iceServers) }

-- | Foreign type for [RTCPeerConnectionIceEvent](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnectionIceEvent).
foreign import data IceEvent :: *

-- | Foreign type for [RTCIceCandidate](https://developer.mozilla.org/en-US/docs/Web/API/RTCIceCandidate).
type RTCIceCandidate = { sdpMLineIndex :: Nullable Int
                       , sdpMid :: Nullable String
                       , candidate :: String
                       }

foreign import _iceEventCandidate
  :: forall a. Maybe a ->
               (a -> Maybe a) ->
               IceEvent ->
               Maybe RTCIceCandidate

-- | Attempts to get the RTCIceCandidate from an IceEvent.
iceEventCandidate :: IceEvent -> Maybe RTCIceCandidate
iceEventCandidate = _iceEventCandidate Nothing Just

-- | Add a candidate to a peer connection.  Corresponds to [addIceCandidate](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/addIceCandidate).
foreign import addIceCandidate
  :: forall e. RTCIceCandidate ->
               RTCPeerConnection ->
               Eff e Unit

-- | Register an event listener when [onicecandidate](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/onicecandidate) is fired.
foreign import onicecandidate
  :: forall e. (IceEvent -> Eff e Unit) ->
               RTCPeerConnection ->
               Eff e Unit


-- A type for [RTCSessionDescription](https://developer.mozilla.org/en-US/docs/Web/API/RTCSessionDescription)
type RTCSessionDescription = { sdp :: String, "type" :: String }

-- https://code.google.com/p/webrtc/issues/detail?id=3282
-- https://bugzilla.mozilla.org/show_bug.cgi?id=1033833
-- http://w3c.github.io/webrtc-pc/#idl-def-RTCOfferOptions
-- | A type corresponding to [http://w3c.github.io/webrtc-pc/#configuration-data-extensions](RTCOfferOptions)
-- | used to create an RTCSessionDescription
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
  :: forall e. (RTCSessionDescription -> Eff e Unit) ->
               (Error -> Eff e Unit) ->
               RTCOfferOptions ->
               RTCPeerConnection ->
               Eff e Unit

-- | Create an RTCSessionDescription offer.  See [createOffer](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/createOffer).
createOffer :: forall e. RTCOfferOptions -> RTCPeerConnection -> Aff e RTCSessionDescription
createOffer options pc = makeAff (\e s -> _createOffer s e options pc)

foreign import _createAnswer
  :: forall e. (RTCSessionDescription -> Eff e Unit) ->
               (Error -> Eff e Unit) ->
               RTCPeerConnection ->
               Eff e Unit

-- | Create an RTCSessionDescription answer.  See [createAnswer](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/createAnswer).
createAnswer :: forall e. RTCPeerConnection -> Aff e RTCSessionDescription
createAnswer pc = makeAff (\e s -> _createAnswer s e pc)

foreign import _setLocalDescription
  :: forall e. Eff e Unit ->
               (Error -> Eff e Unit) ->
               RTCSessionDescription ->
               RTCPeerConnection ->
               Eff e Unit

-- | Sets the local descritpoin associated with the connection. See [setLocalDescription](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/setLocalDescription).
setLocalDescription :: forall e. RTCSessionDescription -> RTCPeerConnection -> Aff e Unit
setLocalDescription desc pc = makeAff (\e s -> _setLocalDescription (s unit) e desc pc)

foreign import _setRemoteDescription
  :: forall e. Eff e Unit ->
               (Error -> Eff e Unit) ->
               RTCSessionDescription ->
               RTCPeerConnection ->
               Eff e Unit

-- | Set remote description associated with the connection.  See [setRemoteDescription](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/setRemoteDescription)
setRemoteDescription :: forall e. RTCSessionDescription -> RTCPeerConnection -> Aff e Unit
setRemoteDescription desc pc = makeAff (\e s -> _setRemoteDescription (s unit) e desc pc)

-- | Foreign type for [RTCDataChannel](https://developer.mozilla.org/en-US/docs/Web/API/RTCDataChannel)
foreign import data RTCDataChannel :: *


-- | Create a data channel for connection. See [createDataChannel](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/createDataChannel)
foreign import createDataChannel
  :: forall e. String ->
               RTCPeerConnection ->
               Aff e RTCDataChannel

-- | Send a string of data over a data channel.
foreign import send
  :: forall e. String ->
               RTCDataChannel ->
               Eff e Unit

-- | Register a listener on a data channel.
foreign import onmessageChannel
  :: forall e. (String -> Eff e Unit) ->
               RTCDataChannel ->
               Eff e Unit

-- | Register a listener on a connection, and return the
-- | RTCDataChannel when the [ondatachannel](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/ondatachannel) event
-- | is fired.
foreign import ondataChannel
  :: forall e. RTCPeerConnection ->
               Aff e RTCDataChannel
