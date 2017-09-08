module Componentry.AddPlayer exposing (..)


import Html exposing (..)
import Html.Attributes exposing (class,type_,id,placeholder, for)
import Html.Events exposing (onInput, onClick, onSubmit)
import Msgs exposing (..)

inputField : Html Msg
inputField =
    input
        [ class "form-control"
        , id "inputNewPlayerName"
        , placeholder "Name"
        , type_ "text"
        , onInput UpdateNewName ]
        []

addPlayerContainer : Html Msg
addPlayerContainer =
    div []
         [ b
            []
            [ text "Add Player" ]
         , form
            [ onSubmit AddNewPlayer
            , class "form-inline" ]
            [ div
                [ class "form-group" ]
                [ inputField
                , submitButton ]]]


submitButton : Html msg
submitButton =
    button
        [ type_ "submit"
        , class "btn btn-outline-primary" ]
        [ text "Submit" ]


-- not used rn
labelTag : Html msg
labelTag =
    label
        [ class "form-control-label"
        , for "inputNewPlayerName" ]
        [ text "Add Player" ]
