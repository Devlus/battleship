import React from "react";

// class!? JavaScript does't have classes
// Apparently ES2015 does though. And we can extend them.
export default class Header extends React.Component {
  render() {
    return (
      <h1>This is the header.</h1>
    );
  }
};