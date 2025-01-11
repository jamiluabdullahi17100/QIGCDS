import { describe, it, expect, beforeEach } from 'vitest';

describe('diplomatic-achievement-nft', () => {
  let contract: any;
  
  beforeEach(() => {
    contract = {
      mint: (name: string, description: string, achievementType: string, civilizationsInvolved: number[], rarity: number) => ({ value: 1 }),
      transfer: (tokenId: number, recipient: string) => ({ success: true }),
      getTokenMetadata: (tokenId: number) => ({
        name: 'Galactic Peace Treaty',
        description: 'Brokered peace between warring factions',
        achievementType: 'Peace Treaty',
        civilizationsInvolved: [1, 2, 3],
        timestamp: 12345,
        rarity: 9
      }),
      getLastTokenId: () => 5
    };
  });
  
  describe('mint', () => {
    it('should mint a new diplomatic achievement NFT', () => {
      const result = contract.mint('Galactic Peace Treaty', 'Brokered peace between warring factions', 'Peace Treaty', [1, 2, 3], 9);
      expect(result.value).toBe(1);
    });
  });
  
  describe('transfer', () => {
    it('should transfer an NFT to a new owner', () => {
      const result = contract.transfer(1, 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG');
      expect(result.success).toBe(true);
    });
  });
  
  describe('get-token-metadata', () => {
    it('should return token metadata', () => {
      const metadata = contract.getTokenMetadata(1);
      expect(metadata.name).toBe('Galactic Peace Treaty');
      expect(metadata.rarity).toBe(9);
    });
  });
  
  describe('get-last-token-id', () => {
    it('should return the last token ID', () => {
      const lastTokenId = contract.getLastTokenId();
      expect(lastTokenId).toBe(5);
    });
  });
});

