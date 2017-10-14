module DOM.HTML.Navigator.Geolocation where

import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Eff.Exception (error)
import DOM (DOM)
import DOM.HTML.Types (Navigator)
import Data.Date (Date)
import Data.Nullable (Nullable)
import Data.Tuple (Tuple(..))
import Prelude (Unit)

-- | The effect type of the location side effect.
foreign import data LOCATION :: Effect

-- | The Geolocation API source provided by the browser.
foreign import data NavigatorGeolocation :: Type

-- | A geolocation object if the current browser supports
-- | the Geolocation API; otherwise, null.
foreign import geolocation
  :: forall eff
  . Navigator
  -> Eff (dom :: DOM | eff) (Nullable NavigatorGeolocation)

-- | The FFI for the
-- | `geolocation.getCurrentPosition` function.
foreign import fGetCurrentPosition
  :: forall eff
  . PositionOptions
  ->
  ( Position
    -> Eff (location :: LOCATION | eff) Unit
  )
  ->
  ( PositionError
    -> Eff (location :: LOCATION | eff) Unit
  )
  -> NavigatorGeolocation
  -> Eff (location :: LOCATION | eff) Unit

-- | The PureScript interface to `navigator.getCurrentPosition`
getCurrentPositionAff
  :: forall eff
  .  PositionOptions
  -> NavigatorGeolocation
  -> Aff (location :: LOCATION | eff) Position
getCurrentPositionAff o g =
  makeAff \err success -> fGetCurrentPosition o success (\e -> err (error e.message)) g

-- | The FFI for `geolocation.watchPosition`
foreign import fWatchPosition
  :: forall a b eff
  . (a -> b -> Tuple a b)
  -> PositionOptions
  ->
  ( Tuple Position Int
    -> Eff (location :: LOCATION | eff) Unit
  )
  ->
  ( PositionError
    -> Eff (location :: LOCATION | eff) Unit
  )
  -> NavigatorGeolocation
  -> Eff (location :: LOCATION | eff) Unit

-- | The PureScript interface to `navigator.watchPosition`
watchPositionAff
  :: forall eff
  .  PositionOptions
  -> NavigatorGeolocation
  -> Aff (location :: LOCATION | eff) (Tuple Position Int)
watchPositionAff o g =
  makeAff \err success -> fWatchPosition Tuple o success (\e -> err (error e.message)) g

-- | The FFI for `geolocation.clearWatch`.
foreign import fClearWatch
  :: forall eff
  .  Int
  -> NavigatorGeolocation
  -> Eff (location :: LOCATION | eff) Unit

-- | Coordinates is the datatype of the coordinates of a position.
-- | The geographic coordinate reference system used by the attributes in this
-- | interface is the World Geodetic System (2d).
type Coordinates = {
    latitude         :: Number,
    longitude        :: Number,
    altitude         :: Nullable Number,
    accuracy         :: Number,
    altitudeAccuracy :: Nullable Number,
    heading          :: Nullable Number,
    speed            :: Nullable Number
}

-- | The container for the geolocation information returned by this
-- | API.
type Position = {
    coords    :: Coordinates,
    timestamp :: Date
}

-- | The error which might be returned by
-- | `getCurrentPosition` and `watchPosition`.
type PositionError = {
    code    :: Int,
    message :: String
}

-- | The options for `getCurrentPosition` and
-- | `watchPosition`.
type PositionOptions = {
    enableHighAccuracy :: Boolean,
    timeout            :: Int,
    maximumAge         :: Int
}

-- | A PositionOptions with reasonable default values.
defaultOptions :: PositionOptions
defaultOptions = {
    enableHighAccuracy: false,
    -- ^ A Boolean that indicates the application would like to receive the best possible
    --  results.
    --  If true and if the device is able to provide a more accurate position,
    --    it will do so. Note that this can result in slower response times or increased
    --    power consumption (with a GPS chip on a mobile device for example).
    --  If false, the device can take the liberty to save resources by
    --    responding more quickly and/or using less power.
    --  Default: false.
    timeout           : 1000,
    -- ^ A positive long value representing the maximum length of time (in milliseconds)
    --    the device is allowed to take in order to return a position.
    --  The default value is Infinity, meaning that getCurrentPosition() won't return until
    --    the position is available.
    maximumAge        : 0
    -- ^ A positive long value indicating the maximum age in milliseconds of a possible
    --    cached position that is acceptable to return.
    --  If set to 0, it means that the device cannot use a cached position and must attempt
    --    to retrieve the real current position.
    --  If set to Infinity the device must return a cached position regardless of its age.
    --  Default: 0.
}

