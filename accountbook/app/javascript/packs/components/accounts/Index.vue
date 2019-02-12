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
            <div class="input-group-prepend">
                <div class="input-group-text">
                    <input type="checkbox" aria-label="Checkbox for following text input" v-model="income">　収入
                </div>
            </div>
        </div>
        <div class="input-group">
            <div class="input-group-prepend">
                <label class="input-group-text" for="inputGroupSelect01">分類</label>
            </div>
            <select class="custom-select" id="inputGroupSelect01" v-model="category" v-for="(ca, key, index) in categories" :key=index>
                <option selected>Choose...</option>
                <option :value="ca.name">{{ca.name}}</option>
            </select>
        </div>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">日付</span>
            </div>
            <date-picker v-model="date" :config="options"></date-picker>
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
import datePicker from 'vue-bootstrap-datetimepicker';

export default {
    data: function() {
        return {
            accounts: [],
            money: "",
            about: "",
            category: "",
            income: false,
            date: null,
            options: {
                format: 'DD/MM/YYYY',
                useCurrent: false
            },
            categories: []
        }
    },
    mounted: function() {
        this.getAccounts();
        this.getCategories();
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
            axios.post('/api/accounts', {account: {money: Number(this.money), date: this.date, income: this.income, about: this.about, category: this.category}}).then((response) => {
                this.accounts.unshift(response.data);
                this.money = "";
                this.about = "";
                this.category = "";
                this.income = false;
            }, (error) => {
                console.log(error);
            })
        },
        getCategories: function() {
            axios.get('/api/categories').then((response) => {
                console.log(response.data);
                for(var i = 0; i < response.data.length; i++){
                    this.categories.push(response.data[i]);
                }
                console.log(this.categories);
            }, (error) => {
                console.log(error);
            })
        }
    },
    components: {
        datePicker
    }
}
</script>
