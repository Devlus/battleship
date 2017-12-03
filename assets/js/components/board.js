import React from "react";
import {channels} from "../socket";

// class!? JavaScript does't have classes Apparently ES2015 does though. And we
// can extend them.
export default class Board extends React.Component {
  constructor(props) {
    super(props);
    this.channel = this.props.channel
    this.state = {
      grid: Array(10).fill(Array(10).fill(0))
      // playerNumber: this.props.playerNumber
    };
  }

  render() {
    debugger;
    return (
      <table>
        {this.state.grid.map((y,j) =>
            (<tr>{y.map((x,i) => (<td className={"cell"} >{i},{j}</td>))}</tr>)
        )}
      </table>
    );
  }
};