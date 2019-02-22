<template>
    <div class="container">
        <payjp-checkout
            :api-key="public_key"
            :client-id="client_id"
            text="add credit crad"
            submit-text="カードで支払い"
            name-placeholder="JOHN DOE"
            v-on:created="onTokenCreated"
            v-on:failed="onTokenFailed">
        </payjp-checkout>

        <qrcode-reader @init="onInit" @decode="onDecode"></qrcode-reader>
    </div>
</template>

<script>
import PayjpCheckout from 'vue-payjp-checkout';
import { QrcodeReader } from 'vue-qrcode-reader';
import axios from 'axios';

export default{
    data: function() {
        return {
            public_key: String(gon.payjp_public_key),
            client_id: String(gon.payjp_client_id)
        }
    },
    components: {
        PayjpCheckout,
        QrcodeReader
    },
    methods: {
        onTokenCreated(token) {
            this.setCreditToken(token.id);
        },
        onTokenFailed(e) {
            console.error(e);
        },
        setCreditToken: function(token) {
            axios.defaults.headers['X-CSRF-TOKEN'] = $('meta[name=csrf-token]').attr('content');
            axios.defaults.headers['content-type'] = 'application/json';
            axios.post('/api/users/set_token', {user: {token: token}}).then((response) => {
                console.log(response);
                alert("Success!");
            }, (error) => {
                console.log(error);
                alert("Failed!");
            })
        },
        async onInit (promise) {
            try {
                    await promise
                } catch (error) {
                    if (error.name === 'NotAllowedError') {
                } else if (error.name === 'NotFoundError') {
                    // no suitable camera device installed
                } else if (error.name === 'NotSupportedError') {
                    // page is not served over HTTPS (or localhost)
                } else if (error.name === 'NotReadableError') {
                    // maybe camera is already in use
                } else if (error.name === 'OverconstrainedError') {
                    // passed constraints don't match any camera. Did you requested the front camera although there is none?
                } else {
                    // browser is probably lacking features (WebRTC, Canvas)
                }
            } finally {
            }
        },
        onDecode: function(decodedString) {
            const price = decodedString;
            var result = confirm('支払いますか？');
            if(result) {
                axios.post('/api/payments', {payment: {price: price, token: this.token}}).then((response) => {
                    console.log(response);
                }, (error) => {
                    console.log(error);
                })
            }
        }
    }
}
</script>