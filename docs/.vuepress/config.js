import { defineUserConfig } from 'vuepress'
import { defaultTheme } from '@vuepress/theme-default'
import { viteBundler } from '@vuepress/bundler-vite'

export default defineUserConfig({
  lang: 'en-US',
  title: 'Azure AVNM IPAM',
  description: 'Azure Virtual Network Manager IP Address Management Solution',
  base: '/Azure-AVNM-IPAM/',
  
  bundler: viteBundler(),
  
  theme: defaultTheme({
    navbar: [
      {
        text: 'Home',
        link: '/',
      },
      {
        text: 'GitHub',
        link: 'https://github.com/tanure/Azure-AVNM-IPAM',
      },
    ],
    sidebar: [
      {
        text: 'Guide',
        children: [
          '/README.md',
          {
            text: 'Getting Started',
            link: '#quick-start',
          },
          {
            text: 'Configuration',
            link: '#configuration',
          },
          {
            text: 'Architecture',
            link: '#architecture-overview',
          },
        ],
      },
    ],
  }),
  
  head: [
    ['link', { rel: 'icon', href: '/Azure-AVNM-IPAM/favicon.ico' }]
  ],
})