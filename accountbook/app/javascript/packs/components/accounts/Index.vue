<template>
    <div class="container">
        <p v-for="(account, key, index) in accounts" :key=index>
            {{account.money}}
        </p>
    </div>
</template>

<script>
import axios from 'axios';

export default {
    data: function() {
        return {
            accounts: []
        }
    },
    mounted: function() {
        this.getAccounts();
    },
    method: {
        getAccounts: function() {
            axios.get('/api/accounts').then(response => {
                for(let i = 0; i < response.data.length; i++) {
                    this.accounts.push(response.data[i]);
                }
            }, (error) => {
                condole.log(error);
            })
        }
    }
}
</script>
