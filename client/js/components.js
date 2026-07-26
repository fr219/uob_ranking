// Component Loader System
const ComponentLoader = {
  // Cache loaded components
  cache: {},

  // Load a component and inject it into an element
  async load(componentName, targetElementId) {
    const target = document.getElementById(targetElementId);
    if (!target) {
      console.error(`Target element #${targetElementId} not found`);
      return;
    }

    // Check cache first
    if (this.cache[componentName]) {
      target.innerHTML = this.cache[componentName];
      this.initializeComponent(componentName, target);
      return;
    }

    try {
      // Fetch the component HTML
      const response = await fetch(`/client/components/${componentName}.html`);
      if (!response.ok) throw new Error(`Failed to load ${componentName}`);
      
      const html = await response.text();
      
      // Cache it
      this.cache[componentName] = html;
      
      // Inject it
      target.innerHTML = html;
      
      // Initialize any scripts in the component
      this.initializeComponent(componentName, target);
      
    } catch (error) {
      console.error(`Error loading component ${componentName}:`, error);
      target.innerHTML = `<div style="color:red">Failed to load ${componentName}</div>`;
    }
  },

  // Initialize component-specific logic
  initializeComponent(componentName, target) {
    // Re-initialize user info if header is loaded
    if (componentName === 'header') {
      const user = JSON.parse(localStorage.getItem('user') || '{}');
      const userNameEl = target.querySelector('#userName');
      const userAvatarEl = target.querySelector('#userAvatar');
      if (userNameEl) userNameEl.textContent = user.name || 'User';
      if (userAvatarEl) {
        const initials = (user.name || 'U').split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2);
        userAvatarEl.textContent = initials;
      }
    }
  },

  // Load multiple components at once
  async loadMultiple(components) {
    const promises = components.map(({ name, target }) => this.load(name, target));
    await Promise.all(promises);
  }
};

// Make it globally available
window.ComponentLoader = ComponentLoader;