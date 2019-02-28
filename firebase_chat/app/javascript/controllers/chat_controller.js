import { Controller } from "stimulus"
import FireBase from 'firebase'

const firebase = FireBase.initializeApp({
    apiKey: String(gon.api_key),
    authDomain: String(gon.auth_domain),
    databaseURL: String(gon.database_url),
    projectId: String(gon.project_id),
    storageBucket: String(gon.storage_bucket),
    messagingSenderId: String(gon.message_senderid)
});

const database = firebase.database();

export default class extends Controller {
    static get targets() {
        return ["chats", "content"]
    }

    initialize() {
        this.update();
    }

    update() {
        const data = database.ref(location.pathname);

        data.on("value", (snapshot) => {
            const firebase_chats = Object.entries(snapshot.val());

            this.chatsTarget.innerHTML = "";

            for (let i = 0; i < firebase_chats.length; i++) {
                this.chatsTarget.innerHTML += `<p>${firebase_chats[i][1].content}</p>`
            }
        }, (error) => {
            console.log(error);
        })

    }

    submit() {
        database.ref(location.pathname).push({
            content: this.contentTarget.value
        });
        this.contentTarget.value = "";
    }
}
