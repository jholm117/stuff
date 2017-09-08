module Main exposing (..)

import Msgs exposing (Msg)
import Models exposing (Model, initialModel)
import Update exposing (update)
import View as View
import Commands exposing (fetchPlayers)
import Routing
import Navigation exposing (Location)
import Pages.Dojo.State as Dojo


init : Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            Routing.parseLocation location
    in
        ( initialModel currentRoute, fetchPlayers )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map Msgs.DojoMsg (Dojo.subscriptions model.dojo) ]



-- MAIN


main : Program Never Model Msg
main =
    Navigation.program Msgs.OnLocationChange
        { init = init
        , view = View.root
        , update = update
        , subscriptions = subscriptions
        }
