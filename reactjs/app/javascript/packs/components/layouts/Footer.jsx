import React from 'react'

const Footer = (props) => {
    const {year} = props
    return (
        <div>
            Created Time {year}
        </div>
    )
}

export default Footer;