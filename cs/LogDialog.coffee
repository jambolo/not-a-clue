`
import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogTitle from '@mui/material/DialogTitle';
import React, { Component } from 'react';
import Stack from '@mui/material/Stack'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'
import Box from '@mui/material/Box'
import Divider from '@mui/material/Divider'
`

PlayerName = ({ name, color }) ->
  <Typography component="span" sx={{ fontWeight: 700, color: color or 'primary.main' }}>{name}</Typography>

CardName = ({ name }) ->
  <Typography component="span" sx={{ fontWeight: 700, color: 'secondary.main', fontStyle: 'italic' }}>{name}</Typography>

VariationName = ({ name }) ->
  <Typography component="span" sx={{ fontWeight: 700, color: 'info.main', letterSpacing: 0.5 }}>{name}</Typography>

cardPhrase = (card, configuration, usePreposition = true) ->
  type = configuration.types[card.type]
  phrase = ""
  phrase += type.preposition if usePreposition
  phrase += type.article
  phrase += card.name
  return phrase

cardPhraseNode = (card, configuration, usePreposition = true) ->
  type = configuration.types[card.type]
  <React.Fragment>
    {if usePreposition then type.preposition else ""}
    {type.article}
    <CardName name={card.name} />
  </React.Fragment>

transcribedList = (list) ->
  string = list[0]
  if list.length > 1
    if list.length > 2
      for i in list[1...-1]
        string += ", " + i
      string += ", and " + list[list.length-1]
    else
      string += " and " + list[1]
  return string

transcribedListNodes = (list) ->
  return "Nobody" if list.length == 0
  result = []
  for item, idx in list
    result.push item
    if idx < list.length - 2
      result.push ", "
    else if idx is list.length - 2
      result.push if list.length > 2 then ", and " else " and "
  return result

playerList = (playerIds) -> if playerIds.length > 0 then transcribedList(playerIds) else "Nobody"

playerListNodes = (playerIds, colorFor) ->
  if playerIds.length > 0
    transcribedListNodes(<PlayerName name={id} color={colorFor?(id)} /> for id in playerIds)
  else
    "Nobody"

cardList = (cardIds, configuration) ->
  cards = configuration.cards
  names = (cardPhrase(cards[id], configuration, false) for id in cardIds)
  return transcribedList(names)

cardListNodes = (cardIds, configuration) ->
  cards = configuration.cards
  names = (cardPhraseNode(cards[id], configuration, false) for id in cardIds)
  return transcribedListNodes(names)

suggestedCardsClause = (cardIds, configuration) ->
  cards = configuration.cards
  suggestionOrder = configuration.suggestionOrder
  card1 = (cards[id] for id in cardIds when cards[id].type is suggestionOrder[0])[0]
  card2 = (cards[id] for id in cardIds when cards[id].type is suggestionOrder[1])[0]
  card3 = (cards[id] for id in cardIds when cards[id].type is suggestionOrder[2])[0]
  clause = cardPhrase(card1, configuration) + " "
  clause += cardPhrase(card2, configuration) + " " 
  clause += cardPhrase(card3, configuration)
  return clause

suggestedCardsClauseNodes = (cardIds, configuration) ->
  cards = configuration.cards
  suggestionOrder = configuration.suggestionOrder
  card1 = (cards[id] for id in cardIds when cards[id].type is suggestionOrder[0])[0]
  card2 = (cards[id] for id in cardIds when cards[id].type is suggestionOrder[1])[0]
  card3 = (cards[id] for id in cardIds when cards[id].type is suggestionOrder[2])[0]
  [
    cardPhraseNode(card1, configuration)
    " "
    cardPhraseNode(card2, configuration)
    " "
    cardPhraseNode(card3, configuration)
  ]

class LogDialog extends Component
  constructor: (props) ->
    super props
    @configuration = null
    @state = { query: "" }
    return

  playerColor: (playerId) ->
    @props.app?.getPlayerColor(playerId) or @props.playerColors?[playerId] or 'primary.main'

  describeSetup: (info) ->
    text = "Playing #{@configuration.name} with #{playerList(info.players)}."
    nodes =
      <React.Fragment>
        {"Playing "}
        <VariationName name={@configuration.name} />
        {" with "}
        {playerListNodes(info.players, (id) => @playerColor(id))}
        {"."}
      </React.Fragment>
    { text, nodes }

  describeHand: (info) ->
    text = "#{info.player} has #{cardList(info.cards, @configuration)}."
    nodes =
      <React.Fragment>
        <PlayerName name={info.player} color={@playerColor(info.player)} />
        {" has "}
        {cardListNodes(info.cards, @configuration)}
        {"."}
      </React.Fragment>
    { text, nodes }

  describeSuggest: (info) ->
    if @configuration.rulesId is "master"
      @describeSuggestMaster info
    else
      @describeSuggestClassic info

  describeSuggestMaster: (info) ->
    text = "#{info.suggester} suggested: #{suggestedCardsClause(info.cards, @configuration)}. #{playerList(info.showed)} showed a card."
    nodes =
      <React.Fragment>
        <PlayerName name={info.suggester} color={@playerColor(info.suggester)} />
        {" suggested: "}
        {suggestedCardsClauseNodes(info.cards, @configuration)}
        {". "}
        {playerListNodes(info.showed, (id) => @playerColor(id))}
        {" showed a card."}
      </React.Fragment>
    { text, nodes }

  describeSuggestClassic: (info) ->
    description = "#{info.suggester} suggested #{suggestedCardsClause(info.cards, @configuration)}."
    if info.showed.length > 0
      if info.showed.length > 1
        description += " #{playerList(info.showed[0...-1])} did not show a card."
      description += " #{info.showed[info.showed.length-1]} showed a card."
    else
      description += " Nobody showed a card."
    detailNodes =
      if info.showed.length > 0
        if info.showed.length > 1
          [
            " "
            playerListNodes(info.showed[0...-1], (id) => @playerColor(id))
            " did not show a card. "
            <PlayerName name={info.showed[info.showed.length-1]} color={@playerColor(info.showed[info.showed.length-1])} />
            " showed a card."
          ]
        else
          [
            " "
            <PlayerName name={info.showed[0]} color={@playerColor(info.showed[0])} />
            " showed a card."
          ]
      else
        " Nobody showed a card."
    nodes =
      <React.Fragment>
        <PlayerName name={info.suggester} color={@playerColor(info.suggester)} />
        {" suggested "}
        {suggestedCardsClauseNodes(info.cards, @configuration)}
        {"."}
        {detailNodes}
      </React.Fragment>
    { text: description, nodes }

  describeShow: (info) ->
    cards = @configuration.cards
    text = "#{info.player} showed #{cardPhrase(cards[info.card], @configuration, false)}."
    nodes =
      <React.Fragment>
        <PlayerName name={info.player} color={@playerColor(info.player)} />
        {" showed "}
        {cardPhraseNode(cards[info.card], @configuration, false)}
        {"."}
      </React.Fragment>
    { text, nodes }

  describeAccuse: (info) ->
    text = "#{info.accuser} made an accusation: #{suggestedCardsClause(info.cards, @configuration)}. The accusation was #{if info.correct then "" else "not "}correct."
    nodes =
      <React.Fragment>
        <PlayerName name={info.accuser} color={@playerColor(info.accuser)} />
        {" made an accusation: "}
        {suggestedCardsClauseNodes(info.cards, @configuration)}
        {". The accusation was "}
        {if info.correct then "correct." else "not correct."}
      </React.Fragment>
    { text, nodes }

  describeCommlink: (info) ->
    text = "#{info.caller} asked #{info.receiver} about #{suggestedCardsClause(info.cards, @configuration)}. #{info.receiver} #{if info.showed then "showed" else "did not show"} a card."
    nodes =
      <React.Fragment>
        <PlayerName name={info.caller} color={@playerColor(info.caller)} />
        {" asked "}
        <PlayerName name={info.receiver} color={@playerColor(info.receiver)} />
        {" about "}
        {suggestedCardsClauseNodes(info.cards, @configuration)}
        {". "}
        <PlayerName name={info.receiver} color={@playerColor(info.receiver)} />
        {if info.showed then " showed a card." else " did not show a card."}
      </React.Fragment>
    { text, nodes }

  describeEntry: (entry) ->
    if entry.setup?
      @describeSetup entry.setup
    else if entry.hand?
      @describeHand entry.hand
    else if entry.suggest?
      @describeSuggest entry.suggest
    else if entry.show?
      @describeShow entry.show
    else if entry.accuse?
      @describeAccuse entry.accuse
    else if entry.commlink?
      @describeCommlink entry.commlink
    else
      alert "Unknown log entry"
      { text: "Unknown log entry", nodes: "Unknown log entry" }

  render: ->
    { open, log, configurations, onClose } = @props
    @configuration = if log[0]? and log[0].setup? then configurations[log[0].setup.variation] else null

    handleDialogClose = (event, reason) ->
      return if reason is 'backdropClick'
      onClose()

    filteredLog = log
      .map((entry) =>
        description = @describeEntry(entry)
        { entry, description }
      )
      .filter((item) =>
        item.description.text.toLowerCase().includes(@state.query.toLowerCase())
      )

    <Dialog open={open} fullScreen={true} onClose={handleDialogClose}>
      <DialogTitle id="form-dialog-title">Session log</DialogTitle>
      <DialogContent dividers>
        <Stack spacing={2}>
          <Box>
            <Typography variant="subtitle1">Search and filter</Typography>
            <TextField
              fullWidth
              size="small"
              placeholder="Search by player or card"
              value={@state.query}
              onChange={(event) => @setState({ query: event.target.value })}
            />
          </Box>
          <Divider />
          {
            if filteredLog.length > 0
              <ol>
                {<li key={step}> {item.description.nodes} </li> for item, step in filteredLog}
              </ol>
            else
              <Typography color="text.secondary">No log entries match your search.</Typography>
          }
        </Stack>
     </DialogContent>
      <DialogActions sx={{ px: 3, py: 2 }}>
        <Button variant="contained" color="primary" onClick={onClose}> Done </Button>
      </DialogActions>
    </Dialog>

export default LogDialog
