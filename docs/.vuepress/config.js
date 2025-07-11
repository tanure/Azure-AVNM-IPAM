import { defaultTheme } from '@vuepress/theme-default'
import { defineUserConfig } from 'vuepress/cli'
import { viteBundler } from '@vuepress/bundler-vite'

export default defineUserConfig({
  lang: 'en-US',
  title: 'Azure AVNM IPAM',
  description: 'Azure Virtual Network Manager IP Address Management Solution for Azure Landing Zones',

  base: '/Azure-AVNM-IPAM/',

  theme: defaultTheme({
    // Public file path
    logo: null,
    
    // Navbar
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

    // Sidebar
    sidebar: [
      {
        text: 'Guide',
        children: [
          '/README.md',
        ],
      },
    ],

    // Page meta
    editLink: true,
    editLinkText: 'Edit this page on GitHub',
    repo: 'tanure/Azure-AVNM-IPAM',
    repoLabel: 'GitHub',
    docsRepo: 'tanure/Azure-AVNM-IPAM',
    docsBranch: 'main',
    docsDir: 'docs',

    // Theme config
    colorMode: 'auto',
    colorModeSwitch: true,
  }),

  bundler: viteBundler(),

  // Site config
  head: [
    ['meta', { name: 'theme-color', content: '#3eaf7c' }],
    ['meta', { name: 'apple-mobile-web-app-capable', content: 'yes' }],
    ['meta', { name: 'apple-mobile-web-app-status-bar-style', content: 'black' }],
  ],
})