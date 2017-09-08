module Utils exposing (..)

import Reponse exposing (..)

udpate -> subaction -> submodel ->

MenuMsg subaction ->
    Menu.update subaction model.menu
      |> mapModel (\x -> { model | menu = x})
      |> mapCmd MenuMsg

updateMap : action -> subaction -> (submsg -> submodel, Cmd Msg) -> model -> model, Cmd Msg
