({
    render: function(component, helper) {
        //grab attributes from the component markup
        var classname = component.get("v.class"),
            xlinkhref = component.get("v.xlinkHref"),
            ariaHidden = component.get("v.ariaHidden"),
            svgColor = component.get("v.svgColor");
        //return an svg element w/ the attributes
        var svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        svg.setAttribute('class', classname);
        // svg.setAttribute('style', 'fill: #0070d2');
        svg.setAttribute('style', 'fill:' + svgColor);
        svg.setAttribute('aria-hidden', ariaHidden);
        //svg.innerHTML = '<use xlink:href="' + xlinkhref + '"></use>';
        
        // Add an "href" attribute (using the "xlink" namespace)
        var shape = document.createElementNS("http://www.w3.org/2000/svg", "use");
        shape.setAttributeNS("http://www.w3.org/1999/xlink", "xlink:href", component.get("v.xlinkHref"));
        svg.appendChild(shape);
        
        return svg;
    },
})