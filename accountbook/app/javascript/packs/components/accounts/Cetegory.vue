<template>
<div>
    <p v-for="(n, key, index) in categories" :key=index>
        {{n.name}}
    </p>
    <div class="input-group">
        <div class="input-group-append">
            <span class="input-group-text">分類名</span>
        </div>
        <input type="text" class="form-control" v-model="name" placeholder="分類名を入力してください"> 
    </div>
    <p>
        <button type="button" class="btn btn-primary" v-on:click="postCategories">button</button>
    </p>
</div>
</template>

 <script>
import axios from 'axios';
 export default {
    data: function() {
        return {
            name: "",
            categories: [],
        }
    },
    mounted: function () {
        this.getCategories();
    },
    methods: {
        getCategories: function() {
            axios.get('/api/categories').then((response) => {
                for(var i = 0; i < response.data.length; i++){
                    this.categories.push(response.data[i]);
                }
            }, (error) => {
                console.log(error);
            })
        },
        postCategories: function() {
            axios.post('/api/categories', {category: {name: this.name}}).then((response) => {
                this.categories.unshift(response.data);
                this.name = '';
            }, (error) => {
                console.log(error);
            });
        },
    },
}
</script> 