module Grid exposing (..)

import Array exposing (Array, toList)
import Bootstrap.Grid as BGrid
import Html exposing (..)
import List exposing (filter, foldl, length)
import List.Split exposing (chunksOfLeft)
import Matrix exposing (Matrix, empty, indexedMap, set)
import Matrix.Extra exposing (neighbours)
import Maybe exposing (withDefault)
import Random exposing (Generator, generate)
import Random.Array exposing (array)
import Random.Extra exposing (choice)


type Msg
    = NewMap (Array Cell)


type alias Model =
    Matrix Cell


type alias Cell =
    { status : CellStatus
    }


type CellStatus
    = Wall
    | Space
    | Player
    | Enemy


type alias Coordinate =
    ( Int, Int )


gridSize : Int
gridSize =
    29


cellAutoGens : Int
cellAutoGens =
    4


initModel : Model
initModel =
    Matrix.empty


initCom : Cmd Msg
initCom =
    generate NewMap randomizeGrid


view : Matrix Cell -> Html msg
view grid =
    let
        cellToText cell =
            case cell.status of
                Wall ->
                    "|"

                Space ->
                    ""

                Player ->
                    "o"

                Enemy ->
                    "x"

        mapCell cell =
            BGrid.col [] [ text <| cellToText cell ]

        mapRow row =
            BGrid.row [] <| List.map mapCell row
    in
        grid
            |> .data
            |> Array.toList
            |> chunksOfLeft gridSize
            |> List.map mapRow
            |> BGrid.containerFluid []


update : Msg -> Model -> Model
update msg model =
    case msg of
        NewMap grid ->
            Matrix ( gridSize, gridSize ) grid
                |> call automaton cellAutoGens


randomizeGrid : Generator (Array Cell)
randomizeGrid =
    choice (Cell Wall) (Cell Space)
        |> array (gridSize * gridSize)


automaton : Matrix Cell -> Matrix Cell
automaton grid =
    let
        gol x y cell =
            let
                friends =
                    neighbours x y grid

                aliveFriends =
                    length <| filter isWall friends
            in
                if length friends < 8 || aliveFriends >= 5 then
                    Cell Wall
                else
                    Cell Space
    in
        indexedMap gol grid


call : (obj -> obj) -> Int -> obj -> obj
call function count obj =
    if count == 0 then
        obj
    else
        function obj
            |> call function (count - 1)


isWall : Cell -> Bool
isWall cell =
    cell.status == Wall


checkForWall : Model -> Coordinate -> Bool
checkForWall model coordinate =
    get coordinate model
        |> withDefault (Cell Wall)
        |> isWall


get : Coordinate -> Matrix a -> Maybe a
get coordinate =
    Matrix.get (Tuple.first coordinate) (Tuple.second coordinate)


set : Coordinate -> a -> Matrix a -> Matrix a
set coordinate =
    Matrix.set (Tuple.first coordinate) (Tuple.second coordinate)


setAsPlayer : Coordinate -> Matrix Cell -> Matrix Cell
setAsPlayer coordinate cellMatrix =
    set coordinate (Cell Player) cellMatrix


setAsSpace : Coordinate -> Matrix Cell -> Matrix Cell
setAsSpace coordinate cellMatrix =
    set coordinate (Cell Space) cellMatrix


setAsWall : Coordinate -> Matrix Cell -> Matrix Cell
setAsWall coordinate cellMatrix =
    set coordinate (Cell Wall) cellMatrix


setAsEnemy : Coordinate -> Matrix Cell -> Matrix Cell
setAsEnemy coordinate cellMatrix =
    set coordinate (Cell Enemy) cellMatrix
