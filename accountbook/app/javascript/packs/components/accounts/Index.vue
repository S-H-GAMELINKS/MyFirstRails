<template>
    <div class="container">
        <p v-for="(account, key, index) in accounts" :key=index>
            {{account.money}}
        </p>
        <p>
            <input v-model="money" class="form-contorl" placeholder="金額を入力してください!">
            <input v-model="about" class="form-control" placeholder="摘要を入力してください!">
            <button type="button" class="btn btn-primary" v-on:click="postAccounts">追加</button>
        </p>
    </div>
</template>

<script>
import axios from 'axios';

export default {
    data: function() {
        return {
            accounts: [],
            money: "",
            about: ""
        }
    },
    mounted: function() {
        this.getAccounts();
    },
    methods: {
        getAccounts: function() {
            axios.get('/api/accounts').then(response => {
                for(let i = 0; i < response.data.length; i++) {
                    this.accounts.push(response.data[i]);
                }
            }, (error) => {
                condole.log(error);
            })
        },
        postAccounts: function() {
            axios.post('/api/accounts', {account: {money: Number(this.money), about: this.about}}).then((response) => {
                this.accounts.unshift(response.data);
                this.money = "";
                this.about = "";
            }, (error) => {
                console.log(error);
            })
        }
    }
}
</script>
