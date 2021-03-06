module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
      backgroundImage: {
        'hero': "url('/images/homepage_header.png')",
        'm-hero': "url('/images/m_homepage_header.png')",
        'hero-topo': "url('/images/icons/topo_circle_bg.png')",
      },
      colors: {
        'pastimes-green': '#52B774',
        'pastimes-green-variant-1': '#48ac68',
        'pastimes-green-variant-2': '#2A944E',
        'pastimes-green-variant-3': '#47AC69',
        'pastimes-green-variant-4': '#e3fceb',
        'pastimes-gray': '#9FA2A7',
        'pastimes-gray-variant-1': '#1c1c1c',
        'pastimes-gray-variant-2': '#c8c8c8',
        'pastimes-gray-variant-3': '#F5F5F5',
        'pastimes-sky-blue': '#F2F4F8',
        'pastimes-blue': '#2A90EC',
        'pastimes-blue-variant-1': '#2788DF',
        'pastimes-blue-variant-2': '#E9F4FE',
        'pastimes-blue-variant-3': '#0C6FC9',
        'pastimes-blue-variant-4': '#2688df',
        'pastimes-yellow-variant-1': '#fff7e8',
        'pastimes-yellow-variant-2': '#FCAF1B',
        'pastimes-orange-variant-1': '#FFECE7',
        'pastimes-orange-variant-2': '#E8582A',
      },
    }
  },
  variants: {},
  plugins: []
};