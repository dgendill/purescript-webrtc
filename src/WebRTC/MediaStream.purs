module WebRTC.MediaStream (
  MediaStream(..)
, MediaStreamConstraints(..)
, Blob(..)
, USER_MEDIA()
, getUserMedia
, mediaStreamToBlob
, createObjectURL
) where

import Prelude (Unit())
import Unsafe.Coerce (unsafeCoerce)
import Control.Monad.Aff (Aff(), makeAff)
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Exception (Error())

-- | Foreign type for [MediaStream](https://developer.mozilla.org/en-US/docs/Web/API/Media_Streams_API#LocalMediaStream).
foreign import data MediaStream :: *

foreign import _getUserMedia
  :: forall e. (MediaStream -> Eff e Unit) ->
               (Error -> Eff e Unit) ->
               MediaStreamConstraints ->
               Eff e Unit

foreign import data USER_MEDIA :: !

-- | Prompt the user for audio/video permission in order to get a `MediaStream`.  See [getUserMedia](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia).
getUserMedia :: forall e. MediaStreamConstraints -> Aff (userMedia :: USER_MEDIA | e) MediaStream
getUserMedia c = makeAff (\e s -> _getUserMedia s e c)

-- Type corresponding to [MediaStreamConstraints](https://developer.mozilla.org/en-US/docs/Web/API/MediaStreamConstraints).
newtype MediaStreamConstraints =
  MediaStreamConstraints { video :: Boolean
                         , audio :: Boolean
                         }

-- | Foreign type for [Blob](https://developer.mozilla.org/en-US/docs/Web/API/Blob).
foreign import data Blob :: *

-- | Convert a `MediaStream` into a `Blob`
mediaStreamToBlob :: MediaStream -> Blob
mediaStreamToBlob = unsafeCoerce

-- | Turn a Blob into a URL.  See [createObjectURL](https://developer.mozilla.org/en-US/docs/Web/API/URL/createObjectURL).
foreign import createObjectURL
  :: forall e. Blob -> Eff e String
