module Main exposing (..)

import Array
import Char
import Dict exposing (Dict)
import Html exposing (Html, button, div, text, h1, h2, p)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Keyboard exposing (..)
import Random
import Styles


-- model


type Direction
    = NoMove
    | Left
    | Up
    | Right
    | Down


init =
    ( { grid = resetGrid
      , score = 0
      , newPosition = ( 0, 0 )
      , initializing = True
      }
    , Cmd.none
    )



-- SUBSCRIPTIONS


subscriptions model =
    let
        directionCode =
            Dict.fromList
                [ ( 37, Left )
                , ( 38, Up )
                , ( 39, Right )
                , ( 40, Down )
                ]
    in
        Keyboard.downs
            (\code ->
                case Dict.get code directionCode of
                    Just dir ->
                        NewDirection dir

                    Nothing ->
                        NoDirection NoMove
            )



-- update


type Msg
    = NoDirection Direction
    | NewDirection Direction
    | NewPosition ( Int, Int )
    | NewNumber ( Int, Int )
    | ResetGrid


insertNumber grid pos num =
    let
        cellNum =
            if num > 90 then
                4
            else
                2
    in
        case (Array.get (Tuple.first pos) grid) of
            Just row ->
                (Array.set (Tuple.first pos) (Array.set (Tuple.second pos) cellNum row) grid)

            Nothing ->
                grid


isPositionAvailable grid pos =
    case (Array.get (Tuple.first pos) grid) of
        Just row ->
            case (Array.get (Tuple.second pos) row) of
                Just cell ->
                    if cell == 0 then
                        True
                    else
                        False

                Nothing ->
                    False

        Nothing ->
            False


randomPos min max =
    Random.pair (Random.int min max) (Random.int min max)


isGridFull grid =
    not (List.any (\row -> List.any (\cell -> cell == 0) (Array.toList row)) (Array.toList grid))


resetGrid =
    Array.initialize 4 (always (Array.initialize 4 (always 0)))


transposeGrid grid =
    case (Array.get 0 grid) of
        Just row ->
            Array.indexedMap
                (\pos cell ->
                    (Array.map
                        (\row ->
                            case Array.get pos row of
                                Just c ->
                                    c

                                Nothing ->
                                    0
                        )
                        grid
                    )
                )
                row

        Nothing ->
            grid


reverseGrid grid =
    Array.map (\row -> Array.fromList (List.reverse (Array.toList row))) grid



-- Merge a row to the left and update score if merged
-- Examples :
-- [2, 0, 0, 2] => [4, 0, 0, 0]
-- [2, 2, 0, 4] => [4, 4, 0, 0]
-- [0, 0, 0, 4] => [4, 0, 0, 0]
-- [0, 0, 2, 4] => [2, 4, 0, 0]
-- [2, 4, 2, 4] => [2, 4, 2, 4]
-- [2, 2, 2, 2] => [4, 4, 0, 0]


mergeEvenLeft row =
    let
        -- Remove zeros
        rowWithouZero =
            List.filter (\num -> num /= 0) row

        -- Then create indexed List
        indexedRow =
            List.indexedMap (,) rowWithouZero
    in
        List.filter (\c -> c /= -1)
            (List.scanl
                (\indexedCell previousMergedCell ->
                    let
                        currentCellIndex =
                            Tuple.first indexedCell

                        currentCell =
                            Tuple.second indexedCell

                        previousCell =
                            if previousMergedCell /= -1 then
                                Array.get (currentCellIndex - 1) (Array.fromList rowWithouZero)
                            else
                                Nothing

                        nextCell =
                            if (Tuple.first indexedCell) < 3 then
                                Array.get (currentCellIndex + 1) (Array.fromList rowWithouZero)
                            else
                                Nothing

                        getMergedCell currentCell nextCell =
                            case nextCell of
                                Just nCell ->
                                    if currentCell == nCell then
                                        currentCell * 2
                                    else
                                        currentCell

                                Nothing ->
                                    currentCell
                    in
                        case previousCell of
                            Just prevCell ->
                                if previousMergedCell /= 0 && prevCell /= previousMergedCell then
                                    0
                                else
                                    getMergedCell currentCell nextCell

                            Nothing ->
                                getMergedCell currentCell nextCell
                )
                -1
                indexedRow
            )


moveLeft row =
    List.filter (\n -> n /= 0) (mergeEvenLeft row)


moveLeftWithZero row =
    let
        leftedRow =
            (moveLeft row)
    in
        List.concat [ leftedRow, (List.repeat (4 - List.length leftedRow) 0) ]


moveGridLeft grid =
    Array.map (\row -> Array.fromList (moveLeftWithZero (Array.toList row))) grid


moveGrid grid dir =
    let
        -- In order to work with only rows, we transpose the grid on up and down moves
        transpose =
            List.member dir [ Up, Down ]

        -- Since the merge algo is only left oriented, we reverse the grid on right and down moves
        reverse =
            List.member dir [ Right, Down ]

        movedGrid =
            if transpose && reverse then
                moveGridLeft (reverseGrid (transposeGrid grid))
            else if transpose then
                moveGridLeft (transposeGrid grid)
            else if reverse then
                moveGridLeft (reverseGrid grid)
            else
                moveGridLeft (grid)
    in
        if transpose && reverse then
            transposeGrid (reverseGrid movedGrid)
        else if transpose then
            transposeGrid movedGrid
        else if reverse then
            reverseGrid movedGrid
        else
            movedGrid


update msg model =
    case msg of
        NoDirection dir ->
            ( model, Cmd.none )

        NewDirection direction ->
            if isGridFull model.grid then
                ( model, Cmd.none )
            else
                ( { model | grid = (moveGrid model.grid direction) }, Random.generate NewPosition (randomPos 0 3) )

        NewPosition pos ->
            if (isPositionAvailable model.grid pos) then
                ( { model | newPosition = pos }, Random.generate NewNumber (randomPos 1 100) )
            else
                ( model, Random.generate NewPosition (randomPos 0 3) )

        NewNumber num ->
            ( { model | grid = (insertNumber model.grid model.newPosition (Tuple.first num)), initializing = False }
            , if model.initializing then
                Random.generate NewPosition (randomPos 0 3)
              else
                Cmd.none
            )

        ResetGrid ->
            ( { model | grid = resetGrid, initializing = True }, Random.generate NewPosition (randomPos 0 3) )



-- view


view model =
    div []
        [ h1 [ Styles.title ] [ text "2048-elm" ]
        , div [ Styles.score ] [ text ("Score " ++ toString model.score) ]
        , button [ onClick ResetGrid ] [ text "New Game" ]
        , div [ Styles.grid ]
            (List.concat
                (Array.toList
                    (Array.map
                        (\row ->
                            Array.toList
                                (Array.map
                                    (\cell ->
                                        div
                                            [ Styles.cell
                                            , (case Dict.get cell Styles.tiles of
                                                Just value ->
                                                    value

                                                Nothing ->
                                                    style []
                                              )
                                            ]
                                            [ if cell == 0 then
                                                text ""
                                              else
                                                text (toString cell)
                                            ]
                                    )
                                    row
                                )
                        )
                        model.grid
                    )
                )
            )
        ]


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
