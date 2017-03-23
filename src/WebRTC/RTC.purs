module WebRTC.RTC (
  RTCPeerConnection(..)
, RTCSessionDescription(..)
, Ice(..)
, IceEvent(..)
, MediaStreamEvent(..)
, RTCIceCandidate(..)
, RTCDataChannel(..)
, ServerType(..)
, newRTCPeerConnection
, addStream
, onicecandidate
, onaddstream
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

import WebRTC.MediaStream
import Control.Alt ((<|>))
import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (Error)
import Data.Argonaut (class DecodeJson, class EncodeJson, Json, decodeJson, encodeJson, getField, jsonEmptyObject, jsonSingletonObject, (:=), (~>))
import Data.Maybe (Maybe(..))
import Data.NonEmpty (NonEmpty)
import Data.Nullable (Nullable)
import Prelude (Unit, bind, pure, unit, ($), (<$>))

-- | Foreign data type for [RTCPeerConnection](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection)
foreign import data RTCPeerConnection :: *

-- | Either a STUN or TURN Server.
-- | See [RTCIceServer](https://developer.mozilla.org/en-US/docs/Web/API/RTCIceServer)
data ServerType
  = STUN { urls :: NonEmpty Array String }
  | TURN { urls :: NonEmpty Array String, credentialType :: Maybe String, credential :: Maybe String, username :: Maybe String }


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

newRTCPeerConnection :: forall e. Ice -> Eff e RTCPeerConnection
newRTCPeerConnection i = newRTCPeerConnection_ { iceServers : (encodeJson <$> i.iceServers) }

foreign import addStream
  :: forall e. MediaStream -> RTCPeerConnection -> Eff e Unit

foreign import data IceEvent :: *

type RTCIceCandidate = { sdpMLineIndex :: Nullable Int
                       , sdpMid :: Nullable String
                       , candidate :: String
                       }

foreign import _iceEventCandidate
  :: forall a. Maybe a ->
               (a -> Maybe a) ->
               IceEvent ->
               Maybe RTCIceCandidate

iceEventCandidate :: IceEvent -> Maybe RTCIceCandidate
iceEventCandidate = _iceEventCandidate Nothing Just

foreign import addIceCandidate
  :: forall e. RTCIceCandidate ->
               RTCPeerConnection ->
               Eff e Unit

foreign import onicecandidate
  :: forall e. (IceEvent -> Eff e Unit) ->
               RTCPeerConnection ->
               Eff e Unit

type MediaStreamEvent = { stream :: MediaStream }

foreign import onaddstream
  :: forall e. (MediaStreamEvent -> Eff e Unit) ->
               RTCPeerConnection ->
               Eff e Unit

type RTCSessionDescription = { sdp :: String, "type" :: String }

-- https://code.google.com/p/webrtc/issues/detail?id=3282
-- https://bugzilla.mozilla.org/show_bug.cgi?id=1033833
-- http://w3c.github.io/webrtc-pc/#idl-def-RTCOfferOptions
type RTCOfferOptions = {
  offerToReceiveAudio :: Boolean,
  offerToReceiveVideo :: Boolean
}

audioVideoRTCOffer = {
  offerToReceiveAudio: true,
  offerToReceiveVideo: true
}

noMediaRTCOffer = {
  offerToReceiveAudio: false,
  offerToReceiveVideo: false
}

foreign import newRTCSessionDescription
  :: { sdp :: String, "type" :: String } -> RTCSessionDescription

foreign import _createOffer
  :: forall e. (RTCSessionDescription -> Eff e Unit) ->
               (Error -> Eff e Unit) ->
               RTCOfferOptions ->
               RTCPeerConnection ->
               Eff e Unit


createOffer :: forall e. RTCOfferOptions -> RTCPeerConnection -> Aff e RTCSessionDescription
createOffer options pc = makeAff (\e s -> _createOffer s e options pc)

foreign import _createAnswer
  :: forall e. (RTCSessionDescription -> Eff e Unit) ->
               (Error -> Eff e Unit) ->
               RTCPeerConnection ->
               Eff e Unit

createAnswer :: forall e. RTCPeerConnection -> Aff e RTCSessionDescription
createAnswer pc = makeAff (\e s -> _createAnswer s e pc)

foreign import _setLocalDescription
  :: forall e. Eff e Unit ->
               (Error -> Eff e Unit) ->
               RTCSessionDescription ->
               RTCPeerConnection ->
               Eff e Unit

setLocalDescription :: forall e. RTCSessionDescription -> RTCPeerConnection -> Aff e Unit
setLocalDescription desc pc = makeAff (\e s -> _setLocalDescription (s unit) e desc pc)

foreign import _setRemoteDescription
  :: forall e. Eff e Unit ->
               (Error -> Eff e Unit) ->
               RTCSessionDescription ->
               RTCPeerConnection ->
               Eff e Unit

setRemoteDescription :: forall e. RTCSessionDescription -> RTCPeerConnection -> Aff e Unit
setRemoteDescription desc pc = makeAff (\e s -> _setRemoteDescription (s unit) e desc pc)

foreign import data RTCDataChannel :: *

foreign import createDataChannel
  :: forall e. String ->
               RTCPeerConnection ->
               Aff e RTCDataChannel

foreign import send
  :: forall e. String ->
               RTCDataChannel ->
               Eff e Unit

foreign import onmessageChannel
  :: forall e. (String -> Eff e Unit) ->
               RTCDataChannel ->
               Eff e Unit

foreign import ondataChannel
  :: forall e. RTCPeerConnection ->
               Aff e RTCDataChannel
