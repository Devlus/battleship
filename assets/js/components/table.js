import React from "react";
import {channels} from "../socket";
import Board from "./board";

// class!? JavaScript does't have classes Apparently ES2015 does though. And we
// can extend them.
export default class Table extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      userId: this.props.userId,
      tableId: this.props.id,
      leftBoard: {player:null},
      rightBoard: {player:null}
    };
    this.channel = channels.tableChannel(this.state.tableId, this.state.userId);
    this
      .channel
      .join()
      .receive("error", () => {
        console.log("Invalid room or userId")
      });

    this
      .channel
      .on("board", (state) => {
        this.state.leftBoard = state.left;
        this.state.rightBoard = state.right;
      });
  }
  leftClaimed() {
    console.log('left');
  }
  rightClaimed() {
    console.log('right');
  }

  render() {
    debugger;
    return (
      <div className="row">
        <div className={"col md-6"}>
          <Board
            board={this.state.leftBoard}
            onClaimed={this
            .leftClaimed
            .bind(this)}
            className={"col md-6"}/>
        </div>
        <div className={"col md-6"}>
          <Board
            board={this.state.rightBoard}
            onClaimed={this
            .rightClaimed
            .bind(this)}
            className={"col md-6"}/>
        </div>
      </div>
    );
  }
};
{/* readonly={this.state.leftBoard.player != this.state.userId} */
}