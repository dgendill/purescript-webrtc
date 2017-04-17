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
import Data.Maybe (Maybe(..))
import Data.NonEmpty (NonEmpty, singleton)
import WebRTC.RTC (Ice, RTC, RTCPeerConnection, RTCSessionDescription(..), ServerType(STUN), addIceCandidate, createAnswer, createDataChannel, createOffer, iceEventCandidate, newRTCPeerConnection, noMediaRTCOffer, ondataChannel, onicecandidate, onmessageChannel, rtcSessionDescriptionSdp, send, setLocalDescription, setRemoteDescription)

url :: String -> { urls :: NonEmpty Array String }
url u = { urls : singleton u }

configuration :: Ice
configuration = {
  iceServers : [
    STUN $ url "stun:stun.l.google.com:3478"
  ]
}

connection :: forall e. Eff (rtc :: RTC | e) RTCPeerConnection
connection = newRTCPeerConnection configuration

getSessionDescriptionWithCandidates :: forall e.
  RTCPeerConnection ->
  Aff (rtc :: RTC, console :: CONSOLE | e) RTCSessionDescription
getSessionDescriptionWithCandidates conn = do
  description <- onicecandidate conn (\evt -> do
    case (iceEventCandidate evt) of
      (Just c) -> do
        Affc.log "ICE Event has candidate.  Connection had candidated added to localDescription automatically."
      Nothing -> Affc.log "ICE Event does not have candidate.  ICE Gathering done."
  )
  Affc.log "Connection's localDescript has had all ice candidates added."
  pure description

main :: forall e. Eff ( rtc :: RTC, err :: EXCEPTION, console :: CONSOLE | e ) Unit
main = void $ launchAff $ do

  Affc.log "Created local peer connection object p1"
  p1 <- liftEff $ connection

  Affc.log "Created remote peer connection object p2"
  p2 <- liftEff $ connection

  forkAff $ do
    p1Data <- createDataChannel "test" p1
    p2Data <- ondataChannel p2
    Affc.log "Data channels 1 and 2 are open"

    forkAff $ do
      -- Wait for data on the channel
      dataString1 <- onmessageChannel p1Data
      Affc.log dataString1

    forkAff $ do
      -- Wait for data on the channel
      dataString2 <- onmessageChannel p2Data
      Affc.log dataString2

    later' 2000 do
      Affc.log "Sending hellos on both channels."
      liftEff $ send "Hello from p1" p1Data
      liftEff $ send "Hello from p2" p2Data

  Affc.log "p1 createOffer start"
  localOffer <- createOffer noMediaRTCOffer p1

  -- Once the local description is set, we can start
  -- gathering candidates
  Affc.log "p1 setLocalDescription start."
  setLocalDescription localOffer p1

  -- Get the session description with the ice candidates
  -- added.  This can take a while to complete.
  offerToShare <- getSessionDescriptionWithCandidates p1

  Affc.log "Offer from pc1"
  Affc.log $ rtcSessionDescriptionSdp offerToShare


  Affc.log "p2 setRemoteDescription start."
  setRemoteDescription offerToShare p2

  Affc.log $ "p2 createAnswer start."
  localAnswer <- createAnswer p2

  Affc.log "p2 setLocalDescription start."
  setLocalDescription localAnswer p2

  -- Get the session description with the ice candidates
  -- added.  This can take a while to complete.
  answerToShare <- getSessionDescriptionWithCandidates p2

  Affc.log "Answer from p2"
  Affc.log $ rtcSessionDescriptionSdp answerToShare

  Affc.log "p1 setRemoteDescription start"
  setRemoteDescription answerToShare p1

  pure unit
