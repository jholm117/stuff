module Componentry.Form exposing (addPlayerForm)

import Html exposing (Html, div, form, input, fieldset, legend, text, button)
import Html.Attributes exposing (placeholder, type_, class, id, action, method)
import Commands exposing (fetchPlayersUrl)
--import Html.Events exposing (..)

type alias InputPlaceholder = String
type alias InputType = String

type alias InputFieldEntry = ( InputPlaceholder, InputType )

newForm : List InputFieldEntry -> Html msg
newForm  list =
    div [ class "center" ]
        [ form [ action fetchPlayersUrl, method "post" ]
            [ fieldset []
                 ( (legend [] [text "Add Player"]) ::
                    (List.map tupleToInput list))
            ]
        ]

-- takes input field info and returns info block
tupleToInput : InputFieldEntry -> Html msg
tupleToInput entry =
    let
        ph = Tuple.first entry
        typ = Tuple.second entry
    in
        input [ placeholder ph, id ph, type_ typ ] []

addPlayerForm : Html msg
addPlayerForm =
    newForm [
        ( "name", "text" ),
        ( "id", "text" ),
        ( "level", "text" ),
        ( "Submit", "submit" )
    ]
