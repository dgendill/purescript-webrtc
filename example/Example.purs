module Example where

import Prelude
import Control.Monad.Aff.Console as Affc
import Control.Monad.Eff.Console as Effc
import Control.Monad.Aff (Aff, forkAff, later', launchAff, makeAff)
import Control.Monad.Aff.Console (CONSOLE)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Foldable (traverse_)
import Data.NonEmpty (NonEmpty, singleton)
import WebRTC.RTC (Ice, RTCPeerConnection, ServerType(STUN), addIceCandidate, createAnswer, createDataChannel, createOffer, iceEventCandidate, newRTCPeerConnection, noMediaRTCOffer, ondataChannel, onicecandidate, onmessageChannel, send, setLocalDescription, setRemoteDescription)

url :: String -> { urls :: NonEmpty Array String }
url u = { urls : singleton u }

configuration :: Ice
configuration = {
  iceServers : [
    STUN $ url "stun:stun.l.google.com:3478"
  ]
}

connection :: forall e. Eff e RTCPeerConnection
connection = newRTCPeerConnection configuration

handleIceCandidate :: forall e. RTCPeerConnection -> RTCPeerConnection -> Aff (console :: CONSOLE | e) Unit
handleIceCandidate p1 p2 = makeAff \e s -> do
  onicecandidate (\evt -> do
    traverse_
      (\c -> do
        Effc.log "ICE Candidate Added"
        addIceCandidate c p2
      )
      (iceEventCandidate evt)

    s unit
  ) p1

main :: forall e. Eff ( err :: EXCEPTION, console :: CONSOLE | e ) Unit
main = void $ launchAff $ do

  Affc.log "Created local peer connection object p1"
  p1 <- liftEff $ connection

  Affc.log "Created remote peer connection object p2"
  p2 <- liftEff $ connection

  forkAff $ handleIceCandidate p2 p1
  forkAff $ handleIceCandidate p2 p1

  forkAff $ do
    p1Data <- createDataChannel "test" p1
    p2Data <- ondataChannel p2
    Affc.log "Data channels 1 and 2 are open"
    later' 2000 do
      Affc.log "Sending hellos on both channels."
      liftEff $ onmessageChannel (\s -> Effc.log s) p1Data
      liftEff $ onmessageChannel (\s -> Effc.log s) p2Data
      liftEff $ send "Hello p1" p1Data
      liftEff $ send "Hello p2" p2Data

  Affc.log "p1 createOffer start"
  offer <- createOffer noMediaRTCOffer p1

  Affc.log "Offer from pc1"
  Affc.log offer.sdp

  Affc.log "p1 setLocalDescription start."
  setLocalDescription offer p1

  Affc.log "p2 setRemoteDescription start."
  setRemoteDescription offer p2

  Affc.log $ "p2 createAnswer start."
  answer <- createAnswer p2

  Affc.log "Answer from p2"
  Affc.log answer.sdp

  Affc.log "p2 setLocalDescription start."
  setLocalDescription answer p2

  Affc.log "p1 setRemoteDescription start"
  setRemoteDescription answer p1

  pure unit
