import React from 'react'

class ListMessages extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      threads: []
    }
  }

  componentDidMount() {
    fetch('/threads.json')
      .then(response => {
        if (response.ok) {
          return response.json()
        }
        throw new Error("Network response was not ok.")
      })
      .then(response => this.setState({ threads: response }))
      .catch(() => this.props.history.push('/'))
  }

  render() {
    const threadList = this.state.threads.map((thread, index) => {
      return (
        <div key={index}>
          <a href={thread.permalink}>{thread.started_at} – {thread.ended_at}</a>
        </div>
      )
    })

    return (
      <section>
        {threadList}
      </section>
    )
  }
}

export default ListMessages
