<template>
  <div id="app">
    <div class="pulse">
      <div id="heart">
        <Heart :bpm="bpm"></Heart>
      </div>
      <h1 id="pulse">{{ bpm }}</h1>
    </div>
    <h2 v-if="timeStamp">Updated: {{ timeStamp }} CST</h2>
    <cite>Heart Rate animation by <a href="https://codepen.io/markhillard/pen/KpLMEa?page=6">Mark Hillard</a></cite>
    <p>Built with <a href="https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-azure-function?WT.mc_id=heartbulb-dotcom-buhollan">Azure Functions</a> and <a href="https://docs.microsoft.com/en-us/azure/azure-signalr/signalr-overview?WT.mc_id=heartbulb-dotcom-buhollan
">Azure SignalR</a></p>
  </div>
</template>

<script>
import * as axios from 'axios';
import * as moment from 'moment';
import * as signalR from '@aspnet/signalr';
const apiBaseUrl = 'https://heart-bulb.azurewebsites.net';

import Heart from './components/Heart';

Date.prototype.addHours = function(h) {
  this.setTime(this.getTime() + h * 60 * 60 * 1000);
  return this;
};

function getConnectionInfo() {
  // return new Promise((resolve, reject) => {
  return axios
    .post(`${apiBaseUrl}/api/getConnectionInfo`)
    .then(result => result.data);
  // });
}

function formatDate(d) {
  // get users timezone offset
  let offset = new Date().getTimezoneOffset();

  return moment(d)
    .format('LLL');
}

export default {
  name: 'app',
  data() {
    return {
      timeStamp: null,
      bpm: 'Loading...'
    };
  },
  components: {
    Heart
  },
  mounted() {
    getConnectionInfo().then(result => {
      let options = {
        accessTokenFactory: () => result.connectionInfo.accessKey
      };

      let connection = new signalR.HubConnectionBuilder()
        .withUrl(result.connectionInfo.endpoint, options)
        .configureLogging(signalR.LogLevel.Information)
        .build();

      connection.on('heartMessage', message => {
        let lastUpdate = formatDate(message.timestamp);

        (this.bpm = message.bpm), (this.timeStamp = lastUpdate);
      });

      connection.start().then(() => {
        this.bpm = result.heartData.bpm;
        this.timeStamp = formatDate(result.heartData.timestamp);
      });
    });
  }
};
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  margin-top: 60px;
  text-align: center;
}

#heart {
  width: 150px;
  display: inline-block;
}

#pulse {
  display: inline-block;
  margin-bottom: -50px;
}

.heart-rate {
  display: inline;
}

h1,
h2 {
  font-weight: normal;
}

h1 {
  margin-top: 10px;
  margin-bottom: 10px;
  font-size: 200px;
}
</style>
