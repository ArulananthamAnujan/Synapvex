import { useEffect, useRef } from 'react';
import * as THREE from 'three';

export default function InteractiveOrbitalScene({ className = '', ariaLabel = 'Interactive connected SynapVex technology ecosystem' }: { className?: string; ariaLabel?: string }) {
  const hostRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const host = hostRef.current;
    if (!host) return;

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(34, 1, 0.1, 100);
    camera.position.set(0, 0.35, 8.4);

    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, powerPreference: 'high-performance' });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.75));
    renderer.outputColorSpace = THREE.SRGBColorSpace;
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.15;
    renderer.setClearColor(0x000000, 0);
    renderer.domElement.className = 'h-full w-full';
    renderer.domElement.setAttribute('aria-hidden', 'true');
    host.appendChild(renderer.domElement);

    const root = new THREE.Group();
    root.rotation.x = -0.08;
    scene.add(root);

    scene.add(new THREE.HemisphereLight(0xeaf9ff, 0x12314b, 2.4));
    const key = new THREE.DirectionalLight(0xffffff, 4.2);
    key.position.set(4, 6, 7);
    scene.add(key);
    const cyan = new THREE.PointLight(0x24c7ee, 16, 14, 2);
    cyan.position.set(-3.5, 1.5, 4);
    scene.add(cyan);
    const gold = new THREE.PointLight(0xf2b84b, 13, 12, 2);
    gold.position.set(3.5, -2, 3);
    scene.add(gold);

    const core = new THREE.Mesh(
      new THREE.IcosahedronGeometry(1.06, 5),
      new THREE.MeshPhysicalMaterial({ color: 0x075985, metalness: 0.22, roughness: 0.08, transmission: 0.16, thickness: 1.2, clearcoat: 1, clearcoatRoughness: 0.08 })
    );
    root.add(core);

    const inner = new THREE.Mesh(
      new THREE.IcosahedronGeometry(0.72, 3),
      new THREE.MeshStandardMaterial({ color: 0x0ea5e9, emissive: 0x075985, emissiveIntensity: 1.4, metalness: 0.45, roughness: 0.2, wireframe: true })
    );
    root.add(inner);

    const ringMaterial = new THREE.MeshPhysicalMaterial({ color: 0xe8c66b, metalness: 0.82, roughness: 0.14, clearcoat: 1 });
    const rings = [
      { radius: 1.65, tube: 0.035, rotation: [1.12, 0.18, 0.2] },
      { radius: 2.05, tube: 0.025, rotation: [0.45, 1.05, -0.2] },
      { radius: 2.42, tube: 0.018, rotation: [1.5, -0.38, 0.35] },
    ].map(({ radius, tube, rotation }) => {
      const ring = new THREE.Mesh(new THREE.TorusGeometry(radius, tube, 16, 180), ringMaterial);
      ring.rotation.set(rotation[0], rotation[1], rotation[2]);
      root.add(ring);
      return ring;
    });

    const panelMaterial = new THREE.MeshPhysicalMaterial({ color: 0xc8efff, transparent: true, opacity: 0.38, transmission: 0.6, roughness: 0.08, metalness: 0.08, side: THREE.DoubleSide });
    const panelPositions: Array<[number, number, number, number]> = [
      [-2.65, 1.55, -0.2, -0.28],
      [2.62, 1.34, -0.35, 0.25],
      [2.55, -1.55, 0.05, -0.22],
      [-2.45, -1.65, -0.1, 0.22],
    ];
    const panels = panelPositions.map(([x, y, z, rz], index) => {
      const group = new THREE.Group();
      const panel = new THREE.Mesh(new THREE.BoxGeometry(1.35, 0.82, 0.075), panelMaterial.clone());
      const edge = new THREE.LineSegments(new THREE.EdgesGeometry(panel.geometry), new THREE.LineBasicMaterial({ color: index % 2 ? 0x38bdf8 : 0xd6b45d, transparent: true, opacity: 0.75 }));
      group.add(panel, edge);
      group.position.set(x, y, z);
      group.rotation.z = rz;
      root.add(group);
      return group;
    });

    const particleGeometry = new THREE.BufferGeometry();
    const particlePositions = new Float32Array(150 * 3);
    for (let i = 0; i < 150; i += 1) {
      const radius = 2.8 + Math.random() * 1.4;
      const angle = Math.random() * Math.PI * 2;
      particlePositions[i * 3] = Math.cos(angle) * radius;
      particlePositions[i * 3 + 1] = (Math.random() - 0.5) * 4.2;
      particlePositions[i * 3 + 2] = (Math.random() - 0.5) * 2.3;
    }
    particleGeometry.setAttribute('position', new THREE.BufferAttribute(particlePositions, 3));
    const particles = new THREE.Points(particleGeometry, new THREE.PointsMaterial({ color: 0x38bdf8, size: 0.025, transparent: true, opacity: 0.62 }));
    root.add(particles);

    const pointer = new THREE.Vector2();
    const target = new THREE.Vector2();
    const handlePointer = (event: PointerEvent) => {
      const rect = host.getBoundingClientRect();
      target.set(((event.clientX - rect.left) / rect.width - 0.5) * 0.65, ((event.clientY - rect.top) / rect.height - 0.5) * 0.45);
    };
    const handleLeave = () => target.set(0, 0);
    host.addEventListener('pointermove', handlePointer);
    host.addEventListener('pointerleave', handleLeave);

    const resize = () => {
      const width = Math.max(host.clientWidth, 1);
      const height = Math.max(host.clientHeight, 1);
      camera.aspect = width / height;
      camera.updateProjectionMatrix();
      renderer.setSize(width, height, false);
    };
    const observer = new ResizeObserver(resize);
    observer.observe(host);
    resize();

    const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    let frame = 0;
    let running = true;
    const clock = new THREE.Clock();
    const render = () => {
      if (!running) return;
      const elapsed = clock.getElapsedTime();
      pointer.lerp(target, 0.045);
      root.rotation.y = pointer.x + (reduceMotion ? 0.12 : elapsed * 0.075);
      root.rotation.x = -0.08 + pointer.y;
      if (!reduceMotion) {
        core.rotation.y = elapsed * 0.18;
        inner.rotation.x = elapsed * -0.22;
        rings.forEach((ring, index) => { ring.rotation.z += 0.0008 * (index + 1); });
        panels.forEach((panel, index) => { panel.position.y += Math.sin(elapsed * 0.8 + index) * 0.00055; });
        particles.rotation.y = elapsed * -0.025;
      }
      renderer.render(scene, camera);
      frame = window.requestAnimationFrame(render);
    };
    render();

    const visibilityObserver = new IntersectionObserver(([entry]) => {
      running = entry.isIntersecting;
      if (running) {
        clock.getDelta();
        frame = window.requestAnimationFrame(render);
      } else {
        window.cancelAnimationFrame(frame);
      }
    }, { threshold: 0.05 });
    visibilityObserver.observe(host);

    return () => {
      running = false;
      window.cancelAnimationFrame(frame);
      observer.disconnect();
      visibilityObserver.disconnect();
      host.removeEventListener('pointermove', handlePointer);
      host.removeEventListener('pointerleave', handleLeave);
      scene.traverse(object => {
        if (object instanceof THREE.Mesh || object instanceof THREE.Points || object instanceof THREE.LineSegments) {
          object.geometry?.dispose();
          const materials = Array.isArray(object.material) ? object.material : [object.material];
          materials.forEach(material => material.dispose());
        }
      });
      renderer.dispose();
      renderer.domElement.remove();
    };
  }, []);

  return (
    <div ref={hostRef} role="img" aria-label={ariaLabel} className={`relative min-h-[420px] overflow-hidden rounded-[2rem] ${className}`}>
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(56,189,248,0.16),transparent_46%)]" />
      <div className="pointer-events-none absolute bottom-5 left-1/2 z-10 -translate-x-1/2 rounded-full border border-white/80 bg-white/65 px-4 py-2 text-[10px] font-bold uppercase tracking-[0.16em] text-sky-900 shadow-sm backdrop-blur-md">Move to explore</div>
    </div>
  );
}
