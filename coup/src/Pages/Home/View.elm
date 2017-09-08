module Pages.Home.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
--import Html.Events exposing (..)


homePage : Html msg
homePage =
    div
        [ class "container" ]
        [ row
            [ col []
            , col [ title ]
            , col []]
        , row
            [ col []
            , col [ menu ]
            , col []]
        , row
            [ col []
            , col []
            , col []] ]


row : List (Html msg) -> Html msg
row list =
    div
        [ class "row" ]
        list

col : List (Html msg) -> Html msg
col list =
    div
        [ class "col-md-1" ]
        list

title : Html msg
title =
    div
        [ class "page-header" ]
        [ h1
            []
            [ text "Coup Arena" ]]


menu : Html msg
menu =
    div
        [ class "btn-group-vertical" ]
        [ playOnlineButton
        , playOfflineButton
        , rulesButton
        , settingsButton]

settingsButton : Html msg
settingsButton =
    button
        [ class "btn btn-default"
        , type_ "button" ]
        [ text "Settings" ]

rulesButton : Html msg
rulesButton =
    button
        [ class "btn btn-default"
        , type_ "button" ]
        [ text "Rules" ]

playOnlineButton : Html msg
playOnlineButton =
    button
        [ type_ "button"
        , class "btn btn-primary" ]
        [ text "Play Online" ]

playOfflineButton : Html msg
playOfflineButton =
    a
        [ type_ "button"
        , class "btn btn-default"
        , href "#dojo" ]
        [ text "Train" ]


flex : Attribute msg
flex =
    style
        [ ("display", "flex") ]
