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
, rtcSessionDescriptionToString
) where

import WebRTC.MediaStream
import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (Error)
import Data.Argonaut (class DecodeJson, class EncodeJson, JObject, decodeJson, encodeJson, fromObject, getField, toObject)
import Data.Argonaut.Core (stringify)
import Data.Either (Either(..))
import Data.Foreign (Foreign, toForeign)
import Data.Foreign.Class (class AsForeign, write)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable)
import Prelude (Unit, unit, (>>>), bind, ($), pure, (<$>))

foreign import data RTCPeerConnection :: *

data ServerType
  = STUN { url :: String }
  | TURN { url :: String, credential :: String, username :: String }


type Ice = { iceServers :: Array ServerType }

instance iceAsForeign :: AsForeign ServerType where
  write (STUN s) = toForeign s
  write (TURN t) = toForeign t

foreign import newRTCPeerConnection_
  :: forall e. { iceServers :: Array Foreign } -> Eff e RTCPeerConnection

newRTCPeerConnection :: forall e. Ice -> Eff e RTCPeerConnection
newRTCPeerConnection i = newRTCPeerConnection_ { iceServers : (write <$> i.iceServers) }

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

foreign import data RTCSessionDescription :: *

foreign import rtcSessionDescriptionToJson :: RTCSessionDescription -> JObject

rtcSessionDescriptionToString :: RTCSessionDescription -> String
rtcSessionDescriptionToString = encodeJson >>> stringify

instance rtcSessionDescriptionEncodeJson :: EncodeJson RTCSessionDescription where
  encodeJson a = fromObject (rtcSessionDescriptionToJson a)

instance rtcSessionDescriptionDecodeJson :: DecodeJson RTCSessionDescription where
  decodeJson json = do
    obj <- decodeJson json
    sdp <- getField obj "sdp"
    t <- getField obj "type"
    pure $ newRTCSessionDescription { "sdp" : sdp, "type" : t }


foreign import newRTCSessionDescription
  :: { sdp :: String, "type" :: String } -> RTCSessionDescription

foreign import _createOffer
  :: forall e. (RTCSessionDescription -> Eff e Unit) ->
               (Error -> Eff e Unit) ->
               RTCPeerConnection ->
               Eff e Unit

createOffer :: forall e. RTCPeerConnection -> Aff e RTCSessionDescription
createOffer pc = makeAff (\e s -> _createOffer s e pc)

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
               Eff e RTCDataChannel

foreign import send
  :: forall e. String ->
               RTCDataChannel ->
               Eff e Unit

foreign import onmessageChannel
  :: forall e. (String -> Eff e Unit) ->
               RTCDataChannel ->
               Eff e Unit
