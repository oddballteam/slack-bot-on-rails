import React from 'react'
import { DateTime } from 'luxon'
import { Grommet, Calendar, DataTable, Grid, Heading, Text } from 'grommet'

const theme = {
  global: {
    font: {
      family: 'Operator Mono Ssm'
    },
  },
}

class ListThreads extends React.Component {
  constructor(props) {
    super()
    let now = DateTime.local()
    this.state = {
      from: now.minus({ months: 1 }).toISODate(),
      to: now.toISODate(),
      threads: []
    }
  }

  fetchData = (options) => {
    this.setState({ threads: [] })
    fetch(`https://oddball-support-bot.herokuapp.com/threads.json?from=${options.from}&to=${options.to}`)
      .then(response => {
        if (response.ok) {
          return response.json()
        }
        throw new Error("Network response was not ok.")
      })
      .then(response => this.setState({ threads: response }))
      .catch(e => console.log('error', e))
  }

  setFromDate = (date) => {
    let isoDate = DateTime.fromISO(date).toISODate()
    this.setState({ from: isoDate })
    this.fetchData({ from: isoDate, to: this.state.to })
  }

  setToDate = (date) => {
    let isoDate = DateTime.fromISO(date).toISODate()
    this.setState({ to: isoDate })
    this.fetchData({ to: isoDate, from: this.state.from })
  }

  componentDidMount() {
    this.fetchData(this.state)
  }

  dateRangeSummary = () => `Displaying threads started between ${this.state.from} and ${this.state.to}`

  render() {
    const { from, to } = this.state
    const dateRange = this.dateRangeSummary()
    const threads = this.state.threads.map(thread => {
      if (thread.started_at) {
        thread.started_at = DateTime.fromISO(thread.started_at).toLocaleString()
      }

      if (thread.created_at) {
        thread.created_at = DateTime.fromISO(thread.created_at).toLocaleString()
      }

      if (thread.ended_at) {
        thread.ended_at = DateTime.fromISO(thread.ended_at).toLocaleString()
      }

      if (thread.category_list && Array.isArray(thread.category_list)) {
        thread.category_list = thread.category_list.join(', ')
      }

      return thread
    })

    return (
      <Grommet theme={theme}>
        <Grid
          rows={['xsmall', 'xsmall', 'large']}
          columns={['small', 'fill', 'small']}
          gap="medium"
          align="start"
          areas={[
            { name: 'left', start: [0, 0], end: [0, 1] },
            { name: 'header', start: [1, 0], end: [1, 0] },
            { name: 'subheader', start: [1, 1], end: [1, 1] },
            { name: 'right', start: [2, 0], end: [2, 1] },
            { name: 'main', start: [0, 2], end: [2, 2] },
          ]}
        >
          <Heading level="1" gridArea="header" textAlign="center">Support Threads</Heading>
          <Heading
            gridArea="subheader"
            level="2"
            size="small"
          >
            {dateRange}
          </Heading>
          <Calendar
            gridArea="left"
            background="light-5"
            size="small"
            date={from}
            onSelect={date => this.setFromDate(date)}
          />
          <DataTable
            columns={[
              {
                property: 'started_at',
                header: <Text>Opened at</Text>,
              },
              {
                property: 'created_at',
                header: <Text>Responded at</Text>,
              },
              {
                property: 'latest_reply_ts',
                header: <Text>Latest reply at</Text>,
              },
              {
                property: 'ended_at',
                header: <Text>Closed at</Text>,
              },
              {
                property: 'channel',
                header: <Text>Channel</Text>,
              },
              {
                property: 'category_list',
                header: <Text>Labels</Text>,
              },
              {
                property: 'started_by',
                header: <Text>Started by</Text>,
              },
              {
                property: 'reply_users',
                header: <Text>Participants</Text>,
              },
              {
                property: 'reply_users_count',
                header: <Text>Total participants</Text>,
              },
              {
                property: 'reply_count',
                header: <Text>Total replies</Text>,
              },
              {
                property: 'link_list',
                header: <Text>Links</Text>,
              },
            ]}
            background={["light-2", "light-5"]}
            data={threads}
            gridArea="main"
            onClickRow={({ item }) => { console.log('click', item) }}
            replace={true}
          />
          <Calendar
            size="small"
            gridArea="right"
            background="light-5"
            date={to}
            onSelect={date => this.setToDate(date)}
          />
        </Grid>
      </Grommet>
    )
  }
}

export default ListThreads
