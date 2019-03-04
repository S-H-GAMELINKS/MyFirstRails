import { Controller } from "stimulus";
import axios from "axios";

export default class extends Controller {
    static get targets() {
        return ["talks", "content"];
    }

    connect() {
        this.load();

        if (this.data.has("refreshInterval")) {
            this.startRefreshing()
        }
    }

    load() {
        axios.get(`${location.pathname}`).then((res) => {
            this.talksTarget.innerHTML = res.data;
        }, (error) => {
            console.log(error);
        })
    }

    submit() {
        axios.post(`${location.pathname}`, { talk: { content: `${this.contentTarget.value}` }}).then((res) => {
            this.contentTarget.value = "";
            console.log(res);
        }, (error) => {
            console.log(error);
        })
    }

    startRefreshing() {
        this.refreshTimer = setInterval(() => {
          this.load()
        }, this.data.get("refreshInterval"))
    }

    stopRefreshing() {
        if (this.refreshTimer) {
          clearInterval(this.refreshTimer)
        }
    }
}