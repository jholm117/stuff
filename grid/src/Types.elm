module Types exposing (..)

import Grid exposing (Coordinate)
import Keyboard


type Msg
    = KeyMsg Keyboard.KeyCode
    | GridMsg Grid.Msg
    | SpawnedMsg Bool (Maybe Coordinate)
    | SpawnMsg Bool


type alias Model =
    { player : Character
    , grid : Grid.Model
    , enemies : List Character
    }


type Direction
    = Up
    | Down
    | Right
    | Left
    | None


type Status
    = Alive Coordinate
    | Dead


type alias Character =
    { status : Status
    , isPlayer : Bool
    }
