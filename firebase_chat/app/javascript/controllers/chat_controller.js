import { Controller } from "stimulus"
import FireBase from 'firebase'

const firebase = FireBase.initializeApp({
    apiKey: process.env.API_KEY,
    authDomain: process.env.AUTH_DOMAIN,
    databaseURL: process.env.DB_URL,
    projectId: process.env.PROJECT_ID,
    storageBucket: process.env.STORAGE_BUCKET,
    messagingSenderId: process.env.MESSAGEING_SENDER_ID
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
