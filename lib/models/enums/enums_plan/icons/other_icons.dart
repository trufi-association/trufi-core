import 'package:flutter_svg/svg.dart';

// import 'icons_bike_rental_network.dart';

const String bike = """
<svg id="icon-icon_park-and-ride" viewBox="0 0 24 12" enable-background="new 0 0 24 12">
      <path fill="#007AC9" d="M22.5,12h-21C0.672,12,0,11.328,0,10.5v-9C0,0.672,0.672,0,1.5,0h21C23.328,0,24,0.672,24,1.5v9   C24,11.328,23.328,12,22.5,12z"></path>
      <path fill="#FFFFFF" d="M22.156,5.313l-0.507,0.13c0.377,0.275,0.521,0.796,0.521,1.158v1.332c0,0.348-0.261,0.652-0.681,0.724   v0.768c0,0.116-0.101,0.174-0.217,0.174h-0.767c-0.101,0-0.203-0.058-0.203-0.174V8.788C19.694,8.817,18.84,8.875,18,8.875   c-0.854,0-1.68-0.058-2.302-0.087v0.637c0,0.116-0.101,0.174-0.203,0.174h-0.767c-0.116,0-0.217-0.058-0.217-0.174V8.658   c-0.405-0.072-0.666-0.376-0.666-0.724V6.601c0-0.362,0.159-0.883,0.536-1.158l-0.536-0.13c-0.217-0.058-0.362-0.232-0.333-0.449   c0.014-0.217,0.232-0.377,0.478-0.362l0.767,0.145l0.521-0.927c0.217-0.405,0.391-0.594,0.912-0.681   c0.565-0.072,0.985-0.13,1.81-0.13c0.811,0,1.274,0.058,1.839,0.13c0.521,0.087,0.695,0.275,0.912,0.681l0.521,0.927l0.753-0.145   c0.232-0.014,0.463,0.145,0.478,0.362C22.532,5.081,22.388,5.255,22.156,5.313z M16.175,6.601l-1.578-0.159v0.405   c0,0.203,0.188,0.333,0.391,0.333h0.811c0.203,0,0.376-0.13,0.376-0.333V6.601z M15.075,5.269   c0.869,0.116,1.969,0.174,2.983,0.174c0.956,0,1.94-0.029,2.896-0.174l-0.666-1.361c-0.116-0.246-0.246-0.348-0.507-0.405   c-0.507-0.101-0.985-0.13-1.781-0.13c-0.796,0-1.245,0.029-1.752,0.13c-0.261,0.058-0.391,0.159-0.507,0.405L15.075,5.269z    M21.446,6.442l-1.549,0.159v0.246c0,0.203,0.174,0.333,0.377,0.333h0.782c0.203,0,0.391-0.13,0.391-0.333V6.442z"></path>
      <path fill="#FFFFFF" d="M6.69,2.026c0.536,0,0.992,0.078,1.368,0.234c0.376,0.155,0.681,0.362,0.918,0.618   c0.236,0.255,0.407,0.548,0.516,0.876s0.161,0.668,0.161,1.02c0,0.344-0.053,0.683-0.161,1.014   C9.384,6.12,9.212,6.413,8.977,6.669C8.739,6.926,8.435,7.132,8.058,7.288C7.682,7.444,7.226,7.522,6.69,7.522H4.71v3.072H2.826   V2.026H6.69z M6.174,6.057c0.216,0,0.423-0.015,0.624-0.047c0.199-0.032,0.376-0.094,0.527-0.186   C7.478,5.732,7.6,5.602,7.692,5.433c0.092-0.167,0.139-0.387,0.139-0.659S7.784,4.282,7.692,4.113   C7.6,3.946,7.478,3.816,7.326,3.724C7.174,3.631,6.998,3.57,6.798,3.538C6.598,3.505,6.39,3.489,6.174,3.489H4.71v2.568H6.174z"></path>
    </svg>
""";

const String parkRide = """
<svg id="icon-icon_park-and-ride" viewBox="0 0 24 12" enable-background="new 0 0 24 12">
      <path fill="#007AC9" d="M22.5,12h-21C0.672,12,0,11.328,0,10.5v-9C0,0.672,0.672,0,1.5,0h21C23.328,0,24,0.672,24,1.5v9   C24,11.328,23.328,12,22.5,12z"></path>
      <path fill="#FFFFFF" d="M22.156,5.313l-0.507,0.13c0.377,0.275,0.521,0.796,0.521,1.158v1.332c0,0.348-0.261,0.652-0.681,0.724   v0.768c0,0.116-0.101,0.174-0.217,0.174h-0.767c-0.101,0-0.203-0.058-0.203-0.174V8.788C19.694,8.817,18.84,8.875,18,8.875   c-0.854,0-1.68-0.058-2.302-0.087v0.637c0,0.116-0.101,0.174-0.203,0.174h-0.767c-0.116,0-0.217-0.058-0.217-0.174V8.658   c-0.405-0.072-0.666-0.376-0.666-0.724V6.601c0-0.362,0.159-0.883,0.536-1.158l-0.536-0.13c-0.217-0.058-0.362-0.232-0.333-0.449   c0.014-0.217,0.232-0.377,0.478-0.362l0.767,0.145l0.521-0.927c0.217-0.405,0.391-0.594,0.912-0.681   c0.565-0.072,0.985-0.13,1.81-0.13c0.811,0,1.274,0.058,1.839,0.13c0.521,0.087,0.695,0.275,0.912,0.681l0.521,0.927l0.753-0.145   c0.232-0.014,0.463,0.145,0.478,0.362C22.532,5.081,22.388,5.255,22.156,5.313z M16.175,6.601l-1.578-0.159v0.405   c0,0.203,0.188,0.333,0.391,0.333h0.811c0.203,0,0.376-0.13,0.376-0.333V6.601z M15.075,5.269   c0.869,0.116,1.969,0.174,2.983,0.174c0.956,0,1.94-0.029,2.896-0.174l-0.666-1.361c-0.116-0.246-0.246-0.348-0.507-0.405   c-0.507-0.101-0.985-0.13-1.781-0.13c-0.796,0-1.245,0.029-1.752,0.13c-0.261,0.058-0.391,0.159-0.507,0.405L15.075,5.269z    M21.446,6.442l-1.549,0.159v0.246c0,0.203,0.174,0.333,0.377,0.333h0.782c0.203,0,0.391-0.13,0.391-0.333V6.442z"></path>
      <path fill="#FFFFFF" d="M6.69,2.026c0.536,0,0.992,0.078,1.368,0.234c0.376,0.155,0.681,0.362,0.918,0.618   c0.236,0.255,0.407,0.548,0.516,0.876s0.161,0.668,0.161,1.02c0,0.344-0.053,0.683-0.161,1.014   C9.384,6.12,9.212,6.413,8.977,6.669C8.739,6.926,8.435,7.132,8.058,7.288C7.682,7.444,7.226,7.522,6.69,7.522H4.71v3.072H2.826   V2.026H6.69z M6.174,6.057c0.216,0,0.423-0.015,0.624-0.047c0.199-0.032,0.376-0.094,0.527-0.186   C7.478,5.732,7.6,5.602,7.692,5.433c0.092-0.167,0.139-0.387,0.139-0.659S7.784,4.282,7.692,4.113   C7.6,3.946,7.478,3.816,7.326,3.724C7.174,3.631,6.998,3.57,6.798,3.538C6.598,3.505,6.39,3.489,6.174,3.489H4.71v2.568H6.174z"></path>
    </svg>
""";

const String car = """
<svg id="icon-icon_car-withoutBox" viewBox="0 0 283.46 283.46">
      <path d="M272.575,118.119l-15.963,4.105c11.859,8.666,16.42,25.085,16.42,36.488v41.96   c0,10.947-8.209,20.524-21.437,22.805v24.173c0,3.648-3.192,5.473-6.841,5.473H220.58c-3.193,0-6.385-1.825-6.385-5.473v-20.069   c-19.155,0.913-46.066,2.737-72.519,2.737c-26.908,0-52.906-1.824-72.518-2.737v20.069c0,3.648-3.193,5.473-6.386,5.473H38.599   c-3.648,0-6.841-1.825-6.841-5.473v-24.173c-12.77-2.28-20.979-11.858-20.979-22.805v-41.96c0-11.402,5.016-27.822,16.875-36.488   l-16.875-4.105c-6.841-1.824-11.402-7.298-10.49-14.139c0.455-6.841,7.297-11.859,15.051-11.402l24.173,4.561l16.418-29.19   c6.841-12.771,12.315-18.7,28.735-21.436c17.788-2.28,31.014-4.105,57.011-4.105c25.542,0,40.136,1.825,57.925,4.105   c16.418,2.736,21.892,8.666,28.734,21.436l16.418,29.19l23.718-4.561c7.297-0.456,14.596,4.561,15.051,11.402   C284.433,110.822,279.872,116.295,272.575,118.119z M84.208,158.712l-49.714-5.017v12.771c0,6.385,5.93,10.49,12.314,10.49h25.543   c6.384,0,11.858-4.105,11.858-10.49V158.712z M49.546,116.751c27.366,3.649,62.028,5.473,93.955,5.473   c30.101,0,61.115-0.912,91.218-5.473l-20.981-42.873c-3.648-7.754-7.753-10.946-15.963-12.77   c-15.963-3.193-31.014-4.105-56.099-4.105s-39.223,0.913-55.187,4.105c-8.209,1.824-12.315,5.017-15.963,12.77L49.546,116.751z    M250.226,153.694l-48.802,5.017v7.754c0,6.385,5.472,10.49,11.859,10.49h24.628c6.386,0,12.315-4.105,12.315-10.49V153.694z"></path>
    </svg>
""";

const String wheelChair = """
<svg id="icon-icon_wheelchair" viewBox="0 0 25 32">
      <g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g id="hsl-reittiasetukset-valikot-auki-pyörä" transform="translate(-557.000000, -1321.000000)" fill="#333333" fill-rule="nonzero">
          <g id="esteettömyys" transform="translate(545.000000, 842.000000)">
            <path d="M24.5,486.8 C26.45,486.8 28.05,485.2 28.05,483.3 C28.05,481.35 26.45,479.75 24.5,479.75 C22.55,479.75 20.95,481.35 20.95,483.3 C20.95,485.2 22.55,486.8 24.5,486.8 Z M21.1,494.85 L28.05,494.8 L28.95,490.15 C29.2,488.5 27.8,487.55 26.3,487.45 L26.15,487.4 L25.35,491.6 L21.1,491.6 L21.1,494.85 Z M20.3,494.8 L20.3,491.55 L20.2,491.6 C18,491.8 18,494.6 20.2,494.8 L20.3,494.8 Z M34.1,507.05 L34.35,506.65 L34.65,506.25 C37.7,501.55 35.8,494.4 30.35,492.5 L29.45,492.1 L28.85,495.05 L29.1,495.2 L29.35,495.3 C33.5,497.15 34.45,503.15 30.85,506.05 L30.6,506.25 L30.4,506.4 C26.3,509.3 21.25,506.4 20.7,501.65 L20.6,501.25 L20.55,500.8 L18.85,505.8 L19.55,506.7 C23.5,511.55 30.05,511.75 34.1,507.05 Z M17.8,506.7 L20.6,498.75 L25.4,498.75 C27.05,498.65 28.1,497.35 28,495.75 L28,495.5 L21.55,495.5 C19.45,495.5 18.05,495.55 17.3,497.75 L15.45,503.3 L13.55,502.8 L12.75,505.2 L17.8,506.7 Z" id="P" transform="translate(24.426671, 495.104609) scale(-1, 1) translate(-24.426671, -495.104609) "></path>
          </g>
        </g>
      </g>
    </svg>
""";

SvgPicture bikeSvg = SvgPicture.string(bike);
SvgPicture parkRideSvg = SvgPicture.string(parkRide);
SvgPicture carSvg = SvgPicture.string(car);
SvgPicture wheelChairSvg = SvgPicture.string(wheelChair);
