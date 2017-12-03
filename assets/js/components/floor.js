import React from "react";
import {channels} from "../socket";

export default class Floor extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tableCode: '',
      userId: ''
    };
    this.channel = channels.floorChannel;
    this.channel.join();

  }

  CreateTable(e) {
    e.preventDefault();
    this
      .channel
      .push("create", {})
      .receive("created", (resp) => {
        this.setState({tableCode: resp.code});
        this.setState({userId: resp.user_id});
      });
  }
  JoinTable(e) {
    e.preventDefault();
    this.props.onGotCode(this.state.tableCode, this.state.userId);
  }

  render() {
    return (
      <form className={"w-25 mt-4"}>
        <div className={"form-group row"}>
          <button
            className={"btn btn-info"}
            onClick={this
            .CreateTable
            .bind(this)}>Create Table</button>
        </div>
        <div className={"input-group"}>
          <input
            className={"form-control"}
            type="text"
            placeholder="Code..."
            value={this.state.tableCode}/>
          <span className={"input-group-btn"}>
            <button
              className={"btn btn-success"}
              onClick={this
              .JoinTable
              .bind(this)}>Join Table</button>
          </span>
        </div>
      </form>
    );
  }
};