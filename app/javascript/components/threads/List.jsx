import React from 'react'
import { DateTime } from 'luxon'
import { Grommet, Calendar, Grid, Header, Heading, List } from 'grommet'

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
    fetch(`/threads.json?from=${options.from}&to=${options.to}`)
      .then(response => {
        if (response.ok) {
          return response.json()
        }
        throw new Error("Network response was not ok.")
      })
      .then(response => this.setState({ threads: response }))
      .catch(() => this.props.history.push('/'))
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
          columns={['small', 'large', 'small']}
          gap="medium"
          areas={[
            { name: 'header', start: [0, 0], end: [2, 0] },
            { name: 'subheader', start: [0, 1], end: [2, 1] },
            { name: 'left', start: [0, 2], end: [0, 2] },
            { name: 'main', start: [1, 2], end: [1, 2] },
            { name: 'right', start: [2, 2], end: [2, 2] },
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
          <List
            gridArea="main"
            background={["light-2", "light-5"]}
            primaryKey="started_at"
            secondaryKey="category_list"
            data={threads}
            onClickItem={({ item, index }) => { console.log('click', item, index) }}
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
