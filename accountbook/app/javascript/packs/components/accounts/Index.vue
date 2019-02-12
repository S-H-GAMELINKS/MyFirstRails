<template>
    <div class="container">
        <p v-for="(account, key, index) in accounts" :key=index>
            {{account.money}}
        </p>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">￥</span>
            </div>
            <input v-model="money" class="form-contorl" placeholder="金額を入力してください!">
        </div>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">摘要</span>
            </div>
            <input v-model="about" class="form-control" placeholder="摘要を入力してください!">
        </div>
        <button type="button" class="btn btn-primary" v-on:click="postAccounts">追加</button>
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
