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

const ListThreads = props => {
  const now = DateTime.local()
  const [from, setFrom] = React.useState(now.minus({ months: 1 }).toISODate())
  const [to, setTo] = React.useState(now.toISODate())
  const [threads, setThreads] = React.useState([])

  React.useEffect(() => {
    fetchData({ to: to, from: from })
  }, [from, to])

  const fetchData = (options) => {
    fetch(`/threads.json?from=${options.from}&to=${options.to}`)
    .then(response => {
      if (response.ok) {
        return response.json()
      }
      throw new Error("Network response was not ok.")
    })
    .then(json => setThreads(json))
    .catch(e => console.log('error', e))
  }

  const setFromDate = (date) => {
    let isoDate = DateTime.fromISO(date).toISODate()
    setFrom(isoDate)
    fetchData({ from: isoDate, to: to })
  }

  const setToDate = (date) => {
    let isoDate = DateTime.fromISO(date).toISODate()
    setTo(isoDate)
    fetchData({ to: isoDate, from: from })
  }

  const dateRangeSummary = () => `Displaying threads started between ${from} and ${to}`
  const data = threads.map(thread => {
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
          {dateRangeSummary()}
        </Heading>
        <Calendar
          gridArea="left"
          background="light-5"
          size="small"
          date={from}
          onSelect={date => setFromDate(date)}
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
              property: 'started_by_name',
              header: <Text>Started by</Text>,
            },
            {
              property: 'reply_users_names',
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
          data={data}
          gridArea="main"
          onClickRow={({ item }) => { console.log('click', item) }}
          primaryKey="id"
          replace={true}
        />
        <Calendar
          size="small"
          gridArea="right"
          background="light-5"
          date={to}
          onSelect={date => setToDate(date)}
        />
      </Grid>
    </Grommet>
  )
}

export default ListThreads
