module Controls exposing (..)

import Keyboard exposing (KeyCode)
import Char exposing (fromCode)
import Types exposing (..)


mapKeys : KeyCode -> Direction
mapKeys keyCode =
    let
        char =
            fromCode keyCode
    in
        if char == 'W' || keyCode == 38 then
            Up
        else if char == 'S' || keyCode == 40 then
            Down
        else if char == 'A' || keyCode == 37 then
            Left
        else if char == 'D' || keyCode == 39 then
            Right
        else
            None
